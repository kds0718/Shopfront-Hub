pragma solidity ^0.4.14;


import "./ShopFrontFactoryInterface.sol";
import "./ShopFront.sol"; 


contract ShopFrontFactory is ShopFrontFactoryInterface {
    
    ShopFront S;

    event LogNewShopfront(address owner, address shopfront);

    function newShopFront()  
        public
        
        returns (address shopfrontContract)
        {
            //Casting the campaign, good to mark trusted/untrusted
            S = new ShopFront(msg.sender);
                        
            LogNewShopfront(msg.sender, S);
            return S; 
        }
}
