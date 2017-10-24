/* Copurchase contract */

pragma solidity ^0.4.14; 

/*My thought is to have buyer1 initiate a copurchase through calling the 
making a coPurchase contract, paying their share. Buyer2 would make a payment to this contract, too. 
Buyer1 and Buyer2 would then initiate a buy through the 'buyFromShopFront()'.I started off trying to make this a smaller process with 
less functions but then it grew again... are there more ways to shorten in down keeping the security?*/

import "./CopurchaseInterface.sol";
import "./ShopFrontInterface.sol";

contract Copurchase is CopurchaseInterface {
    mapping (address => bool) public buyers; 
    
    struct Confirmations {
        uint count; 
        mapping (address => bool) confirmed; 
    }
    
    mapping (bytes32 => Confirmations) public confirmations; 
    mapping (address => uint) public copurchaseBalance; 
    /* Ideally should make sure that this is a valid shopfront, instead of a random address. 
    Could verify with ShopFrontHub in future.*/
    
    address public buyer1;
    address public buyer2; 

   
    event OnUnfinishedConfirmation(bytes32 key);
        
    /*Aiming to make each copurchase contract unique to each purchase here - this makes it easier to
    verify that the payment/balance of this contract is for a specific purchase rather than just a 
    general agreement between two parties to purchase 'something' - sendToShopfront() might accidently send
    the wrong balance to theShopfront otherwise. */
    
    function Copurchase(address buyerno2, address shopfront)
        public
        payable
    {
        require(msg.sender != buyerno2 && buyerno2 != 0);
        buyers[msg.sender]=true;
        buyers[buyerno2] =true;
        

        copurchaseBalance[msg.sender] += msg.value;
        buyer1 = msg.sender;
        buyer2 = buyerno2; 
    }
    
    modifier fromBuyer {require(buyers[msg.sender]); _;}
    
    modifier isValidCoBuy {
        bytes32 key = hashData(msg.data);
        if (confirmations[key].confirmed[msg.sender]) {
            return;
        }
        confirmations[key].count++; 
        confirmations[key].confirmed[msg.sender] = true; 
        if (confirmations[key].count < 2) {
            OnUnfinishedConfirmation(key);
            return;
        }
        delete confirmations[key];
        _;
    }
    
    function hashData(bytes data)
        public
        constant
        returns (bytes32 hashed)
        {
            return sha3(data);
        }
    
    function payForCopurchase()
        fromBuyer
        public
        payable
        returns (bool success)
    {
        /*The first buyer can also put money in the contract via contract creation. However, 
        the second buyer will need to have a way to add money to this contract as well. 
        Mapping balances to buyers address in case they want to change their minds.*/
        copurchaseBalance[msg.sender] += msg.value; 
        return true; 
    }
    
    function withdrawlCopurchase()
        fromBuyer
        public
        returns (bool success)
    {
        require(copurchaseBalance[msg.sender]>0);
        uint valueToSend = copurchaseBalance[msg.sender];
        copurchaseBalance[msg.sender] = 0;
        msg.sender.transfer(valueToSend);
        return true; 
    }
    
    function buyFromShopFront(address shopfront, bytes32 theId, uint howMany)
        public
        fromBuyer
        isValidCoBuy
        payable
        returns (bool success)
    {
        copurchaseBalance[msg.sender] += msg.value; 
        uint inTotal = this.balance; 
        /* Getting the cost so that the contract can send the right amount 
        to the shopfront */
        uint theCost = ShopFrontInterface(shopfront).getTheETHCost(theId, howMany);
        /*To Do - Think of how any left over money would get out of the contract. Could assume
        50/50 and do some math to make sure left over goes to each buyers balance. */
        
        ShopFrontInterface(shopfront).soloBuyProduct.value(theCost)(theId, howMany);

        copurchaseBalance[buyer1] = 0;
        copurchaseBalance[buyer2] = 0; 
        
        return true; 
        
    }       
    
}