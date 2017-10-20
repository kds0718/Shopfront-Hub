/* Refactoring Shopfront for Hub & Spokes. 
Hub: Site admin
Store Owner: Ability to add, remove products, make payments etc. 
Customer: Ability to buy products, ability to co-purchase products. 
3rd Party Coin: Creation of the 3rd party coin. */


pragma solidity ^0.4.6;

/* I am thinking along the lines of anybody being able to create their own shopfront. So
anyone can launch a shopfront and allow merchants to sell there. */
import "./Stoppable.sol";
import "./ShopFront.sol";
import "./BetterToken.sol";

contract ShopFrontHub is Stoppable {
    
    address[] public shopfronts; //Keep list of shopfronts created.
    //Mapping below is a safeguard feature for using addresses within other functions
    mapping(address => bool) shopfrontExists; //Default is false, checking if campaigns are existing
    
    //Central Repository for All SKUs
    struct AllProducts {
        address shopfront;
        address merchant; 
        bytes32 prodId; 
        uint    price; //Price per unit in Ether. 
        uint    altprice; 
        uint    stock; 
        bool    avail; 
    }
    
    AllProducts public allProducts; 
    
    //Checking if the shopfront exists
    modifier onlyIfShopfront(address shopfront) { 
        if (shopfrontExists[shopfront]!=true)throw; 
        _;
    }
    
    event LogNewGlobalProduct(address shopfront, address merchant, bytes32 anId, uint price, uint altprice, uint stock);
    event LogNewShopfront(address owner, address shopfront);
    event LogShopfrontStop(address sender, address shopfront);
    event LogShopfrontStart(address sender, address shopfront);
    event LogNewShopfrontOwner(address sender, address shopfront, address newOwner);
    
    
    
    function getShopfrontCount()
        public 
        constant 
        returns (uint shopfrontCount)
        {
            return shopfronts.length;
        }
        
    function newShopfront()  
        public
        returns (address shopfrontContract)
        {
            //Casting the campaign, good to mark trusted/untrusted
            ShopFront trustedShopfront = new ShopFront(msg.sender); 
             
            shopfronts.push(trustedShopfront);
            shopfrontExists[trustedShopfront] = true; 
            LogNewShopfront(msg.sender, trustedShopfront);
            return trustedShopfront; 
        }
     
     function newGlobalProduct(address shopfront, address merchant, bytes32 theId, uint price, uint altprice, uint stock)
        public
        onlyIfShopfront(shopfront)
        returns (bool success)
     {
         allProducts.shopfront = shopfront; 
         allProducts.merchant = merchant; 
         allProducts.prodId = theId; 
         allProducts.price = price; 
         allProducts.altprice = altprice;
         allProducts.stock = stock; /* Would need a way to reconcile stock with purchases/updates in shopfronts...*/
         allProducts.avail = true; 
         LogNewGlobalProduct(shopfront, merchant, theId, price, altprice, stock);
         return true; 
     }
     
    // Pass-thru Admin Controls
    
    function stopShopfront(address shopfront)
        onlyOwner
        onlyIfShopfront(shopfront)
        returns (bool success)
    {
        
        ShopFront trustedShopfront = ShopFront(shopfront);
        LogShopfrontStop(msg.sender, shopfront);
        return(trustedShopfront.runSwitch(false));
    }
    
    function startShopfront(address shopfront)
        onlyOwner
        onlyIfShopfront(shopfront)
        returns (bool succcess)
    {
        ShopFront trustedShopfront = ShopFront(shopfront); 
        LogShopfrontStart(msg.sender, shopfront);
        return(trustedShopfront.runSwitch(true));
    }
    
    function changeShopfrontOwner(address shopfront, address newOwner)
        onlyOwner
        onlyIfShopfront(shopfront)
        returns (bool success)
    {
        ShopFront trustedShopfront = ShopFront(shopfront); 
        LogNewShopfrontOwner(msg.sender, shopfront, newOwner);
        return(trustedShopfront.changeOwner(newOwner));
    }
    
}
