
pragma solidity ^0.4.14;

contract CopurchaseInterface {
    function Copurchase(address buyerno2, address shopfront, bytes32 theId, uint howMany) payable; 
    function hashData(bytes data) constant returns (bytes32 hashed);
    function payForCopurchase() public payable returns(bool success);
    function withdrawlShopfront() public returns(bool success);
    function sendToShopfront(address shopfront, bytes32 theId, uint howMany) public returns (bool success);
}