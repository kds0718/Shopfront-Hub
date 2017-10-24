/* Refactoring Shopfront for Hub & Spokes. 
Hub: Site admin
Store Owner: Ability to add, remove products, make payments etc. 
Customer: Ability to buy products, ability to co-purchase products. 
3rd Party Coin: Creation of the 3rd party coin. */


pragma solidity ^0.4.14;

import "./Stoppable.sol";
import "./HubInterface.sol";
import "./ShopFrontFactoryInterface.sol";
import "./StoppableInterface.sol";
import "./OwnedInterface.sol";
import "./ShopFrontInterface.sol";

contract Hub is Stoppable, HubInterface {
      

    address[] public shopFronts; //Keep list of shopfronts created.
    //Mapping below is a safeguard feature for using addresses within other functions
    mapping(address => bool) shopFrontExists; //Default is false, checking if campaigns are existing
    
    //Central Repository for All SKUs
    struct AllProducts {
        
        address merchant; 
        
        uint    price; //Price per unit in Ether. 
        uint    altprice; 
        uint    stock; 
        bool    avail; 
    }
    
     
    /* Mapping the shopfront address to the item id. Each product should have a unique id.
    Should allow each unique product in a unique shopfront to be identified. */ 
    mapping (address => mapping(bytes32 => AllProducts)) public allProducts;
    
    // Factory Interface
    ShopFrontFactoryInterface f;
    
    //Checking if the shopfront exists
    modifier onlyIfShopFront(address shopfront) { 
        require(shopFrontExists[shopfront]==true); 
        _;
    }
    
    // Event Logs
    event LogNewShopFront(address admin, address newShopFront);
    event LogNewGlobalProduct(address shopfront, address merchant, bytes32 anId, uint price, uint altprice, uint stock);
    event LogShopFrontStop(address sender, address shopfront);
    event LogShopFrontStart(address sender, address shopfront);
    event LogNewShopfrontOwner(address sender, address shopfront, address newOwner);
    
    //Constructor
    function Hub(address sfFactory) {
        f = ShopFrontFactoryInterface(sfFactory);
    }
    
    function getShopfrontCount()
        public 
        constant 
        returns (uint shopfrontCount)
        {
            return shopFronts.length;
        }
        
    function createShopfront()  
        public
        returns (address shopfrontContract)
        {
            //Casting the campaign, good to mark trusted/untrusted
             address trustedShopfront = f.newShopFront(); 
              
             shopFronts.push(trustedShopfront);
             shopFrontExists[trustedShopfront] = true; 
             LogNewShopFront(msg.sender, trustedShopfront);
             return trustedShopfront; 
        }
     
     function newGlobalProduct(address shopfront, address merchant, bytes32 theId, uint thePrice, uint theAltPrice, uint theStock)
        public
        onlyIfShopFront(shopfront)
        returns (bool success)
     {
         /* To Do - Implement a way to reconcile stock and price changes with shopfront. */
          
         allProducts[shopfront][theId].price = thePrice; 
         allProducts[shopfront][theId].altprice = theAltPrice;
         allProducts[shopfront][theId].stock = theStock; 
         allProducts[shopfront][theId].avail = true; 
         LogNewGlobalProduct(shopfront, merchant, theId, thePrice, theAltPrice, theStock);
         return true; 
     }
     
    // Pass-thru Admin Controls

    function changeRunSwitch(address shopfront, bool toChange)
        public
        onlyOwner
        onlyIfShopFront(shopfront)
        returns (bool success)
    {
        if (toChange==true) {
            LogShopFrontStart(msg.sender, shopfront);
        } else if(toChange == false) {
            LogShopFrontStop(msg.sender, shopfront);
        }
        success = StoppableInterface(shopfront).runSwitch(toChange);
        return success; 
    }
       
    function changeShopFrontOwner(address shopFront, address newOwner)
        public
        onlyOwner
        onlyIfShopFront(shopFront)
        returns (bool success)
    {
       
       LogNewShopfrontOwner(msg.sender, shopFront, newOwner);
       /*Changing the recorded admin in the shopfront as well. */
       ShopFrontInterface(shopFront).changeAdmin(newOwner); 
       return(OwnedInterface(shopFront).changeOwner(newOwner)); 
    }

    //If there end up being multiple Hubs? Or a Hub needs to be reworked and redeployed? 
    function changeHubinShopFront(address shopFront, address newHub)
        public
        onlyOwner
        onlyIfShopFront(shopFront)
        returns(bool success)
        {
            /*Event logged in ShopFront */
            success = ShopFrontInterface(shopFront).changeHub(newHub);
            return  success; 
        }   
}
