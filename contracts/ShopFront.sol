 //Shopfront Example Practice

pragma solidity ^0.4.14;

import "./Stoppable.sol";
import "./Copurchase.sol"; 
import "./ShopFrontHub.sol";
import "./BetterTokenInterface.sol"; 
import "./CopurchaseInterface.sol";

contract ShopFront is Stoppable, Copurchase

{
    address public admin; //Site admin

    address public theHub;    
    
    
    //Struct of all products on the website
    struct OurProducts {
        address merchant; 
        uint    price; //Price per unit in Ether. 
        uint    altprice;
        uint    stock; 
        bool    avail; //True when a product is available. False when it is removed. 
    }
    
    //BetterToken Interface
    BetterTokenInterface B; 
    
    /*Map the ID of each object to the struct of their Merchant, Price, & Stock */
    mapping (bytes32 => OurProducts) public ourProducts; 
    
    //Mapping balance values to addresses of merchants and the admin.
    mapping (address => uint) public balances;
    mapping (address => uint256) public SFCbalances;
    
    //Event logs
    event  LogProductAddition(address aMerchant, bytes32 anItemId, uint aPrice, uint altPrice, uint aStock);
    event  LogProductPurchased(address aBuyer, bytes32 boughtId, uint boughtStock);
    event  LogProductRemoval(address aMerchant, bytes32 anItemId, uint aPrice, uint altPrice, uint aStock);
    
    //Mapping of a mapping to coPurchase
    mapping (address => mapping(address => uint256)) combinedMoney; 
    mapping (address => mapping(address => bytes32)) itemToPurchase;
    
    modifier onlyAdmin  { require(msg.sender == admin); _;}
    modifier onlyMerchant(address possibleM, bytes32 prodId) { require(ourProducts[prodId].merchant == possibleM); _; }
    modifier prodAvail(bytes32 theId) {require(ourProducts[theId].avail == true); _;}


//Constructor
function ShopFront(address shopfrontOwner) {
    admin = shopfrontOwner;
    theHub = msg.sender; 
    
}    

//Function to add products to the website.
function addNewProduct(bytes32 theId, uint thePrice, uint theAltPrice, uint theStock)
    onlyIfRunning
    public
    returns (bool success)
{
    //Cases to throw
    require(theStock != 0); 
    require(thePrice > 0); //Since this is a uint entry it could be enter as negative
    require(theAltPrice > 0);
    
    /*To Do - Think of a way to have a merchant be validated so that not just anyone
    can update here. Valid list of merchants? */
    require(ourProducts[theId].merchant != msg.sender); 

    //Build the struct (with account to be done outside the contract)
    ourProducts[theId].merchant = msg.sender; 
    ourProducts[theId].price = thePrice;
    ourProducts[theId].altprice = theAltPrice; 
    ourProducts[theId].stock += theStock;
    ourProducts[theId].avail = true; 

    //Add an event to product addition 
    LogProductAddition(msg.sender, theId, thePrice, theAltPrice, theStock);
    /*Rework for Shopfront interface*/
    
    /*Assumption to only keep track of SKUs - prices and stock changes updates would need to be included */
    require(ShopFrontHubInterface(theHub).newGlobalProduct(this, msg.sender, theId, thePrice, theAltPrice, theStock));
    return true; 
}

/* Make a reduce stock function for practice with 'SafeMath' */

//To change the amount of stock for a product
function addStock(bytes32 theId, uint theStock)
    onlyIfRunning
    onlyMerchant(msg.sender, theId)
    prodAvail(theId)
    public
    returns (bool success)
    {
        require(theStock!=0);
        ourProducts[theId].stock += theStock; 
        return true; 
    }
    
//To reduce stock if needed - and practice safemath
function reduceStock(bytes32 theId, uint reduceThisMuch)
    onlyIfRunning
    onlyMerchant(msg.sender, theId)
    prodAvail(theId)
    public
    returns (bool success)
    {
        require(ourProducts[theId].stock >= reduceThisMuch);
        ourProducts[theId].stock -= reduceThisMuch;
        return true;
    }
    

//To change the price of an item
function changePrice(bytes32 theId, uint newETHPrice, uint newTOKPrice)
    onlyIfRunning
    onlyMerchant(msg.sender, theId)
    prodAvail(theId)
    public
    returns (bool success)
    {
        require(newETHPrice != 0 && newTOKPrice !=0);
        ourProducts[theId].price = newETHPrice;
        ourProducts[theId].altprice = newTOKPrice; 
        return true; 
        
    }

/*Function to buy a product in Ether- but the instructions said as a 'regular user', does
that mean I need to keep a register of users?*/ 
function soloBuyProduct(bytes32 theId, uint howMany)
    onlyIfRunning
    prodAvail(theId)
    public
    payable
    returns (bool success)
{
    //Cases to throw
    /* Must request more than 0 and must have enough in stock.*/
    uint toMerchant = 98; //Percentage to merchant
    OurProducts memory product = ourProducts[theId];
    require(howMany > 0); 
    require(product.stock >= howMany);
    /* Requiring the purchaser to pay exact. Do not want to deal with returning 
    leftover money */
    require(msg.value == product.price); 
    /* Vendor cannot buy their own product, false advertising data.*/
    require(msg.sender != product.merchant);
    
    product.stock -= howMany;
    
    /* Logging a purchase */
    LogProductPurchased(msg.sender, theId, howMany);
    
    /* Allot balances to merchant and owner. */
    balances[product.merchant] += msg.value*(toMerchant/100);
    balances[admin] += (msg.value - (msg.value*toMerchant));
    return true; 

}

/*Function to cobuy a product. This assumes that cobuyer #1 initiates a Copurchase contract
through Copurchase(buyer2). The cobuyer #1 will need to then call coBuy() as well  */

function coBuy(bytes32 theId, uint howMany, address copurchaseContract)
    onlyIfRunning
    prodAvail(theId)
    isValidCoBuy
    public
    payable
    returns (bool success)
{
    uint toMerchant = 98; //Percentage to merchant
    OurProducts memory product = ourProducts[theId];
    require(howMany > 0); 
    require(product.stock >= howMany);
    /* Requiring the purchaser to pay exact. Do not want to deal with returning 
    leftover money */
    uint copurchaseBalance = copurchaseContract.balance;
    require(copurchaseBalance == product.price); 
    /* Vendor cannot buy their own product, false advertising data.*/
    require(msg.sender != product.merchant);
    product.stock -= howMany;
    
    require(CopurchaseInterface(copurchaseContract).sendToShopfront(this, theId, howMany));
     
    /* Event logged in copurchase contract because I wanted to get a way to 
    log both buyers of the purchase */
    return true; 
    
}
    


//Function with ability to remove product.
function removeProduct(bytes32 removeId)
    onlyIfRunning
    prodAvail(removeId)
    public
    returns (bool success)

{
    OurProducts memory product = ourProducts[removeId];
    /*Product should exist in the site.*/
    require(product.merchant != 0); 
    /* Only merchants or the admin should be able to remove product. */
    require(msg.sender == ourProducts[removeId].merchant || msg.sender == admin);
    
    /* Switch availability boolean from true to false. */
    ourProducts[removeId].avail = false; 
    
    /*Log Product Removal */
    LogProductRemoval(product.merchant, removeId, product.price, product.altprice, product.stock);
    
    return true; 
}

//Function to be able to make a payment to shopfront admin.  
function makePaymentShopfront() 
    onlyIfRunning
    public
    payable
    returns (bool success)
{
    balances[admin] += msg.value;
}

//Function to be able to withdrawl according to mapped balances
function withdrawlShopfront() 
    onlyIfRunning
    public
    returns (bool success)
{
   /* Only those with balanaces mapped to their addresses can withdrawl. 
   So, people that paid for "co-purchases" can withdrawl if they decide not to purchase in the end */
    require(balances[msg.sender]>0);
    uint thePayment = balances[msg.sender];
    balances[msg.sender] = 0;
    /*Switching from .send to .transfer, transfer will throw if it doesn't work */
    msg.sender.transfer(thePayment); 
    return true; 
}

/* Function should not be payable because it is not payable in Ether */
function buyWithSFC(uint256 sfCoins, bytes32 itemId, uint howMany, address theToken)
    onlyIfRunning
    prodAvail(itemId)
    public
    returns (bool success)
    {
        uint merPiece = 98; //Percentage
        require(howMany>0);
        uint totalCost = ourProducts[itemId].altprice * howMany;
        require(sfCoins==totalCost);
        require(ourProducts[itemId].stock >= howMany);
        address approver = msg.sender;
        
        /* Accounting for sending balances */
        address theMerchant = ourProducts[itemId].merchant; 
        uint forMerchant = sfCoins*(merPiece/100);
        uint forAdmin = sfCoins - (forMerchant);
        
        /* Sending balances directly to the admin and merchant. */
        require(BetterTokenInterface(theToken).transferFrom(approver, theMerchant, forMerchant));
        require(BetterTokenInterface(theToken).transferFrom(approver, admin, forAdmin));
        ourProducts[itemId].stock -= howMany; 
        
        LogProductPurchased(msg.sender, itemId, howMany);
    
        return true; 
    }

}

