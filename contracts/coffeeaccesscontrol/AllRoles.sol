pragma solidity ^0.5.15;


contract AllRoles {
    enum RoleType {None, Farmer, Distributor, Retailer, Consumer}
    mapping(address => RoleType) roles;
    event RoleChanged(address indexed account, RoleType newRole);

    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier isFarmer() {
        require(hasRole(msg.sender, RoleType.Farmer), "Not Farmer");
        _;
    }
    modifier isDistributor() {
        require(hasRole(msg.sender, RoleType.Distributor), "Not Distributor");
        _;
    }
    modifier isRetailer() {
        require(hasRole(msg.sender, RoleType.Retailer), "Not Retailer");
        _;
    }
    modifier isConsumer() {
        require(hasRole(msg.sender, RoleType.Consumer), "Not Consumer");
        _;
    }

    function hasRole(address _acc, RoleType role) public view returns (bool) {
        return roles[_acc] == role;
    }

    function setRole(address acc, RoleType role) public {
        require(
            hasRole(msg.sender, role) || msg.sender == owner,
            "UNAUTHORIZED"
        );
        roles[acc] = role;

        emit RoleChanged(acc, role);
    }

    function removeRole(address acc) public {
        require(msg.sender == acc || msg.sender == owner, "UNAUTHORIZED");
        delete roles[acc];

        emit RoleChanged(acc, RoleType.None);
    }
}
