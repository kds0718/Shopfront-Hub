pragma solidity ^0.4.14;

contract ShopFrontFactoryInterface {
    function newShopFront() public returns (address shopfrontContract);
}