
pragma solidity ^0.4.14;

contract CopurchaseInterface {
    function hashData(bytes data) public constant returns (bytes32 hashed);
    function payForCopurchase() public payable returns (bool success); 
    function withdrawlCopurchase() public returns (bool success); 
    function buyFromShopFront(address shopfront, bytes32 theId, uint howMany) public payable returns(bool success);
    //function sendToShopfront(address shopfront, bytes32 theId, uint howMany) public returns (bool success);
}