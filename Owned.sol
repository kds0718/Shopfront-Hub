//This will be the owner of the website/shopfront hub

pragma solidity ^0.4.14;


contract Owned {
    address public owner; 
    
    event LogNewOwner(address sender,address oldOwner, address newOwner);
    
    modifier onlyOwner  { require(msg.sender==owner); _;}
    
    function Owned(){
        owner = msg.sender; 
    }
    
    function changeOwner(address newOwner)
        onlyOwner
        returns (bool success)
        {
            //Ensuring someone cannot forget to supply an address
            require(newOwner != 0); 
            LogNewOwner(msg.sender, owner, newOwner); 
            owner = newOwner; 
            return true; 
        }
    
}