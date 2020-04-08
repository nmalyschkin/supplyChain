// migrating the appropriate contracts
// var FarmerRole = artifacts.require("./FarmerRole.sol");
// var DistributorRole = artifacts.require("./DistributorRole.sol");
// var RetailerRole = artifacts.require("./RetailerRole.sol");
// var ConsumerRole = artifacts.require("./ConsumerRole.sol");
var AllRoles = artifacts.require("./AllRoles.sol");
var SupplyChain = artifacts.require("./SupplyChain.sol");

module.exports = function (deployer) {
    deployer.deploy(AllRoles);
    deployer.deploy(SupplyChain);
};
