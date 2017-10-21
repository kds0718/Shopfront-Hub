pragma solidity ^0.4.14;

contract ShopFrontInterface {
    function ShopFront(address shopfrontOwner);
    function addNewProduct(bytes32 theId, uint thePrice, uint theAltPrice, uint theStock) returns (bool success);
    function addStock(bytes32 theId, uint theStock) returns (bool success);
    function reduceStock(bytes32 theId, uint reduceThisMuch) returns (bool success);
    function changePrice(bytes32 theId, uint newETHPrice, uint newTOKPrice) returns (bool success);
    function soloBuyProduct(bytes32 theId, uint howMany) payable returns (bool success);
    function coBuy(bytes32 theId, uint howMany, address copurchaseContract) payable returns (bool success);
    function removeProduct(bytes32 removeId) returns (bool success);
    function makePaymentShopfront() payable returns (bool success);
    function withdrawlShopfront() returns (bool success);
    function buyWithSFC(uint256 sfCoins, bytes32 itemId, uint howMany, address theToken) returns (bool success);
}