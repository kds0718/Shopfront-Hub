/* Copurchase contract */

pragma solidity ^0.4.14; 

/*My thought is to have buyer1 initiate a copurchase through calling the 
making a coPurchase contract, paying their share. Buyer2 would make a payment to this contract, too. 
Buyer1 and Buyer2 would then initiate a buy through the 'CoBuy()' function in ShopFront which will use
the isValidCoBuy modifier to verify the transaction. I started off trying to make this a smaller process with 
less functions but then it grew again... are there more ways to shorten in down keeping the security?*/

import "./CopurchaseInterface.sol";

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
    address public theShopfront; 
    address public buyer1;
    address public buyer2; 
    bytes32 public itemId;
    uint    public amount;
   
    event OnUnfinishedConfirmation(bytes32 key);
    event  LogProductCoPurchased(address Buyer1, address Buyer2 , bytes32 boughtId, uint boughtStock);
    
    /*Aiming to make each copurchase contract unique to each purchase here - this makes it easier to
    verify that the payment/balance of this contract is for a specific purchase rather than just a 
    general agreement between two parties to purchase 'something' - sendToShopfront() might accidently send
    the wrong balance to theShopfront otherwise. */
    
    function Copurchase(address buyerno2, address shopfront, bytes32 theId, uint howMany)
        payable
    {
        require(msg.sender != buyer2 && buyer2 != 0);
        buyers[msg.sender]=true;
        buyers[buyer2] =true;
        theShopfront = shopfront; 
        itemId = theId; 
        amount = howMany; 
        copurchaseBalance[msg.sender] += msg.value;
        buyer1 = msg.sender;
        buyerno2 = buyer2; 
        
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
    
    function withdrawlShopfront()
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
    
    function sendToShopfront(address shopfront, bytes32 theId, uint howMany)
        public
        returns (bool success)
    {
        /*Verify that this is for the right purchase. What if there is more than 
        one copurchase going on between two parties?*/
        require(theId == itemId);
        require(howMany == amount);
        /*Ensure that the shopfront is the one withdrawing the money, not any other
        address.*/
        require(msg.sender == theShopfront);
        uint toSend = this.balance;
        shopfront.transfer(toSend);
        LogProductCoPurchased(buyer1, buyer2, theId, howMany);
        return true; 
    }
        
    
}