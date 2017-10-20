//This will be the owner of the website/shopfront

pragma solidity ^0.4.6;


contract Owned {
    address public owner; 
    
    event LogNewOwner(address sender,address oldOwner, address newOwner);
    
    modifier onlyOwner  { if(msg.sender != owner) throw; _;}
    
    function Owned(){
        owner = msg.sender; 
    }
    
    function changeOwner(address newOwner)
        onlyOwner
        returns (bool success)
        {
            //Ensuring someone cannot forget to supply an address
            if(newOwner == 0) throw; 
            LogNewOwner(msg.sender, owner, newOwner); 
            owner = newOwner; 
            return true; 
        }
    
}
