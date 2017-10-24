
pragma solidity ^0.4.14;

contract ShopFrontHubInterface {
    function ShopFrontHub(address theShopFrontFactory); 
    function getShopfrontCount() public constant returns (uint shopfrontCount);
    function createShopfront() public returns (address shopfrontContract);
    function newGlobalProduct(address shopfront, address merchant, bytes32 theId, uint price, uint altprice, uint stock) public returns (bool success);
    function stopShopfront(address shopfront) returns (bool success);
    function startShopfront(address shopfront) returns (bool success);
    function changeShopfrontOwner(address shopfront, address newOwner) returns (bool success);
}
