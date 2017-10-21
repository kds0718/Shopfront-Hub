pragma solidity ^0.4.14;

import "./ShopFront.sol";
import "./ShopFrontFactoryInterface.sol";
import "./ShopFrontHub.sol";

contract ShopFrontFactory is ShopFrontFactoryInterface, ShopFrontHub, ShopFront {
    
    event LogNewShopfront(address owner, address shopfront);

    function ShopFrontFactory()  
        public
        onlyOwner
        returns (address shopfrontContract)
        {
            //Casting the campaign, good to mark trusted/untrusted
            ShopFront anewShopfront = new ShopFront(msg.sender);
                        
            LogNewShopfront(msg.sender, anewShopfront);
            return anewShopfront; 
        }
}