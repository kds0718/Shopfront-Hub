
pragma solidity ^0.4.14;

contract CopurchaseInterface {
    function Copurchase(address buyer2, address theShopfront, bytes32 theId, uint howMany);
    function hashData(bytes data) constant returns (bytes32 hashed);
    function payForCopurchase() payable returns(bool success);
    function withdrawl() returns(bool success);
    function sendToShopfront(address shopfront, bytes32 theId, uint howMany) returns (bool success);
}