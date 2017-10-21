
pragma solidity ^0.4.14;

contract ShopFrontHubInterface {
    function getShopfrontCount() constant returns (uint shopfrontCount);
    function newShopfront() returns (address shopfrontContract);
    function newGlobalProduct(address shopfront, address merchant, bytes32 theId, uint price, uint altprice, uint stock) returns (bool success);
    function stopShopfront(address shopfront) returns (bool success);
    function startShopfront(address shopfront) returns (bool success);
    function changeShopfrontOwner(address shopfront, address newOwner) returns (bool success);
}