
pragma solidity ^0.4.14;

contract HubInterface {
     function getShopfrontCount() public constant returns (uint shopfrontCount);
     function createShopfront() public returns (address shopfrontContract);
     function newGlobalProduct(address shopfront, address merchant, bytes32 theId, uint price, uint altprice, uint stock) public returns(bool success);
     function changeRunSwitch(address shopFront, bool toChange) public returns(bool success);
     function changeShopFrontOwner(address shopFront, address newOwner) public returns(bool success);
     function changeHubinShopFront(address shopFront, address newHub) public returns (bool success);
}