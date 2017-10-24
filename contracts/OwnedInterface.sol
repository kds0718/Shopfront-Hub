pragma solidity ^0.4.14; 

contract OwnedInterface {
    
    function changeOwner(address newOwner) returns (bool success);

}