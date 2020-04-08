pragma solidity ^0.5.15;

import "../coffeeaccesscontrol/AllRoles.sol";


contract SupplyChain is AllRoles {
    address payable owner;

    uint256 upc;

    uint256 sku;

    mapping(uint256 => Item) items;

    enum State {
        Harvested, // 0
        Processed, // 1
        Packed, // 2
        ForSale, // 3
        Sold, // 4
        Shipped, // 5
        Received, // 6
        Purchased // 7
    }

    State constant defaultState = State.Harvested;

    struct Item {
        uint256 sku;
        uint256 upc;
        address ownerID;
        // Farmer
        address originFarmerID;
        string originFarmName;
        string originFarmInformation;
        string originFarmLatitude;
        string originFarmLongitude;
        // Product
        uint256 productID;
        string productNotes;
        uint256 productPrice;
        State itemState;
        // IDs
        address distributorID;
        address retailerID;
        address consumerID;
    }

    // Product Update Events
    event Harvested(uint256 upc);
    event Processed(uint256 upc);
    event Packed(uint256 upc);
    event ForSale(uint256 upc);
    event Sold(uint256 upc);
    event Shipped(uint256 upc);
    event Received(uint256 upc);
    event Purchased(uint256 upc);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier verifyCaller(address _address) {
        require(msg.sender == _address, "UNAUTHORIZED");
        _;
    }

    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price, "not enough tokens provided");
        _;
    }

    modifier checkValue(uint256 _upc) {
        _;
        uint256 _price = items[_upc].productPrice;
        uint256 amountToReturn = msg.value - _price;
        msg.sender.transfer(amountToReturn);
    }

    modifier isState(State _state, uint256 _upc) {
        require(items[_upc].itemState == _state, "item in wrong state");
        _;
    }

    constructor() public payable {
        owner = msg.sender;
        sku = 1;
        upc = 1;
    }

    function kill() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }

    function harvestItem(
        uint256 _upc,
        address _originFarmerID,
        string memory _originFarmName,
        string memory _originFarmInformation,
        string memory _originFarmLatitude,
        string memory _originFarmLongitude,
        string memory _productNotes
    ) public isFarmer() {
        Item memory _item = Item({
            sku: sku,
            upc: _upc,
            ownerID: _originFarmerID,
            originFarmerID: _originFarmerID,
            originFarmName: _originFarmName,
            originFarmInformation: _originFarmInformation,
            originFarmLatitude: _originFarmLatitude,
            originFarmLongitude: _originFarmLongitude,
            productID: sku + _upc,
            productPrice: 0,
            productNotes: _productNotes,
            itemState: defaultState,
            distributorID: address(0),
            retailerID: address(0),
            consumerID: address(0)
        });

        items[_upc] = _item;
        sku = sku + 1;

        emit Harvested(_upc);
    }

    function processItem(uint256 _upc)
        public
        isState(State.Harvested, _upc)
        verifyCaller(items[_upc].ownerID)
    {
        Item storage _item = items[_upc];
        _item.itemState = State.Processed;

        emit Processed(_upc);
    }

    function packItem(uint256 _upc)
        public
        isState(State.Processed, _upc)
        verifyCaller(items[_upc].ownerID)
    {
        Item storage _item = items[_upc];
        _item.itemState = State.Packed;

        emit Packed(_upc);
    }

    function sellItem(uint256 _upc, uint256 _price)
        public
        isState(State.Packed, _upc)
        verifyCaller(items[_upc].ownerID)
    {
        Item storage _item = items[_upc];
        _item.productPrice = _price;
        _item.itemState = State.ForSale;

        emit ForSale(_upc);
    }

    function buyItem(uint256 _upc)
        public
        payable
        isState(State.ForSale, _upc)
        paidEnough(items[_upc].productPrice)
        checkValue(_upc)
        isDistributor()
    {
        Item storage _item = items[_upc];
        address payable farmer = address(uint160(_item.ownerID));

        farmer.transfer(_item.productPrice);
        _item.ownerID = msg.sender;
        _item.distributorID = msg.sender;
        _item.itemState = State.Sold;

        emit Sold(_upc);
    }

    function shipItem(uint256 _upc)
        public
        isState(State.Sold, _upc)
        verifyCaller(items[_upc].ownerID)
    {
        Item storage _item = items[_upc];
        _item.itemState = State.Shipped;

        emit Shipped(_upc);
    }

    function receiveItem(uint256 _upc)
        public
        isState(State.Shipped, _upc)
        isRetailer()
    {
        Item storage _item = items[_upc];

        _item.ownerID = msg.sender;
        _item.retailerID = msg.sender;
        _item.itemState = State.Received;

        emit Received(_upc);
    }

    function purchaseItem(uint256 _upc)
        public
        isState(State.Received, _upc)
        isConsumer()
    {
        Item storage _item = items[_upc];

        _item.ownerID = msg.sender;
        _item.consumerID = msg.sender;
        _item.itemState = State.Purchased;

        emit Purchased(_upc);
    }

    function fetchItemBufferOne(uint256 _upc)
        public
        view
        returns (
            uint256 itemSKU,
            uint256 itemUPC,
            address ownerID,
            address originFarmerID,
            string memory originFarmName,
            string memory originFarmInformation,
            string memory originFarmLatitude,
            string memory originFarmLongitude
        )
    {
        Item memory item = items[_upc];

        return (
            item.sku,
            item.upc,
            item.ownerID,
            item.originFarmerID,
            item.originFarmName,
            item.originFarmInformation,
            item.originFarmLatitude,
            item.originFarmLongitude
        );
    }

    function fetchItemBufferTwo(uint256 _upc)
        public
        view
        returns (
            uint256 itemSKU,
            uint256 itemUPC,
            uint256 productID,
            string memory productNotes,
            uint256 productPrice,
            uint256 itemState,
            address distributorID,
            address retailerID,
            address consumerID
        )
    {
        Item memory item = items[_upc];

        return (
            item.sku,
            item.upc,
            item.productID,
            item.productNotes,
            item.productPrice,
            uint256(item.itemState),
            item.distributorID,
            item.retailerID,
            address(item.consumerID)
        );
    }
}
