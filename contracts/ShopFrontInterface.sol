pragma solidity ^0.4.14;

contract ShopFrontInterface {
    //function ShopFront(address shopfrontOwner);
    function changeAdmin(address newAdmin) public returns(bool success);
    function changeHub(address newHub) public returns (bool success);
    function addNewProduct(bytes32 theId, uint thePrice, uint theAltPrice, uint theStock) public returns (bool success);
    function addStock(bytes32 theId, uint theStock) public returns(bool success);
    function reduceStock(bytes32 theId, uint reduceThisMuch) public returns (bool success);
    function changePrice(bytes32 theId, uint newETHPrice, uint newTOKPrice) public returns (bool success);
    function getTheETHCost(bytes32 theId, uint howMany) public constant returns (uint theCost);
    function soloBuyProduct(bytes32 theId, uint howMany) public payable returns (bool success);
    function removeProduct(bytes32 removeId) public returns (bool success);
    function makePaymentShopfront() public payable returns (bool success);
    function withdrawlShopfront() public returns (bool success);
    function buyWithSFC(uint256 sfCoins, bytes32 itemId, uint howMany, address theToken) public returns(bool success);
}