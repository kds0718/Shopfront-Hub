//Deploy the Hub
var ShopFrontFactory = artifacts.require("./ShopFrontFactory.sol");
var Hub = artifacts.require("./Hub.sol");

var sfFactory = ShopFrontFactory.deployed().then(sfFactory => sfFactory.address);
module.exports = function(deployer) {
  deployer.deploy(Hub, sfFactory)
};

