/* Refactoring Shopfront for Hub & Spokes. 
Hub: Site admin
Store Owner: Ability to add, remove products, make payments etc. 
Customer: Ability to buy products, ability to co-purchase products. 
3rd Party Coin: Creation of the 3rd party coin. */


pragma solidity ^0.4.14;

import "./Stoppable.sol";
import "./StoppableInterface.sol";
import "./OwnedInterface.sol";
import "./ShopFrontHubInterface.sol";
import "./ShopFrontFactoryInterface.sol";

 

contract ShopFrontHub is Stoppable, ShopFrontHubInterface {
    
    //ShopFrontFactory Interface
    ShopFrontFactoryInterface f; 
    

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
        require(shopfrontExists[shopfront]==true); 
        _;
    }
    
    // Event Logs
    event LogNewGlobalProduct(address shopfront, address merchant, bytes32 anId, uint price, uint altprice, uint stock);
    event LogShopfrontStop(address sender, address shopfront);
    event LogShopfrontStart(address sender, address shopfront);
    event LogNewShopfrontOwner(address sender, address shopfront, address newOwner);
    
    //Constructor?
    function ShopFrontHub(address theShopFrontFactory){
        f = ShopFrontFactoryInterface(theShopFrontFactory);
    }
    
    function getShopfrontCount()
        public 
        constant 
        returns (uint shopfrontCount)
        {
            return shopfronts.length;
        }
        
    function createShopfront()  
        public
        returns (address shopfrontContract)
        {
            //Casting the campaign, good to mark trusted/untrusted
            address trustedShopfront =  f.newShopFront();
            
            shopfronts.push(trustedShopfront);
            shopfrontExists[trustedShopfront] = true; 
            
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
        
        //ShopFront trustedShopfront = ShopFront(shopfront);
        LogShopfrontStop(msg.sender, shopfront);
        return(StoppableInterface(shopfront).runSwitch(false));
    }
    
    function startShopfront(address shopfront)
        onlyOwner
        onlyIfShopfront(shopfront)
        returns (bool succcess)
    {
         
        LogShopfrontStart(msg.sender, shopfront);
        return(StoppableInterface(shopfront).runSwitch(true));
    }
    
    function changeShopfrontOwner(address shopfront, address newOwner)
        onlyOwner
        onlyIfShopfront(shopfront)
        returns (bool success)
    {
         
        LogNewShopfrontOwner(msg.sender, shopfront, newOwner);
        return(OwnedInterface(shopfront).changeOwner(newOwner));
    }
    
}
