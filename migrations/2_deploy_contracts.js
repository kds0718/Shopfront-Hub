var BetterToken = artifacts.require("./BetterToken.sol");
var ShopFrontFactory = artifacts.require("./ShopFrontFactory.sol");
var Hub = artifacts.require("./Hub.sol");

//Deploy BetterToken and ShopFrontFactory
module.exports = function(deployer) {
  deployer.deploy(BetterToken);
  deployer.deploy(ShopFrontFactory);
};



