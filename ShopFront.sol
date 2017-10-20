 //Shopfront Example Practice


import "./Stoppable.sol";
import "./BetterToken.sol";
import "./ShopFrontHub.sol";

pragma solidity ^0.4.6;


contract ShopFront is Stoppable {
    address public admin; //Site admin

    address public theHub;     
    
    //Struct of all products on the website
    struct OurProducts {
        address merchant; 
        uint    price; //Price per unit in Ether. 
        uint    altprice;
        uint    stock; 
        uint    noReserved; //This is so during a co-purchase the product is reserved when the first buyer initiates the buy.
        bool    avail; //True when a product is available. False when it is removed. 
    }
    /*Map the ID of each object to the struct of their
    Merchant, Price, & Stock */
    mapping (bytes32 => OurProducts) public ourProducts; 
    
    mapping (address => uint) public balances;
    mapping (address => uint256) public SFCbalances;

    event  LogProductAddition(address aMerchant, bytes32 anItemId, uint aPrice, uint altPrice, uint aStock);
    event  LogProductPurchased(bytes32 aBuyer, bytes32 boughtId, uint boughtStock);
    event  LogProductCoPurchased(bytes32 theBuyers, bytes32 boughtId, uint boughtStock);
    
    //Mapping of a mapping to coPurchase
    mapping (address => mapping(address => uint256)) combinedMoney; 
    mapping (address => mapping(address => bytes32)) itemToPurchase;
    
    modifier onlyAdmin  { if(msg.sender != admin) throw; _;}
    /* I thought about having a 'onlyMerchant' modifier, but it would need 
    to test for a specific merchant each time. Is that possible> */
    modifier onlyMerchant(address possibleM, bytes32 prodId) { if(ourProducts[prodId].merchant != possibleM) throw; _; }
    modifier prodAvail(bytes32 theId) {if (ourProducts[theId].avail != true) throw; _;}

    //Mapping balance values to addresses of merchants.

    
    //Event logs

    
//Constructor
function ShopFront(address shopfrontOwner) {
    admin = shopfrontOwner;
    theHub = msg.sender; 
    
}    

//Function to add products to the website
function addNewProduct(bytes32 theId, uint thePrice, uint theAltPrice, uint theStock)
    onlyIfRunning
    public
    returns (bool success)
{
    //Cases to throw
    require(theStock != 0); 
    require(thePrice != 0); 
    /* What is if a merchant tries to add more stock to an existing product
    but tries to put a different price. Added new function for add stock. */
    require(ourProducts[theId].merchant != msg.sender); /* If they have already
    the product, they should just be adding stock. To Do - 1. If they need to change the price, 
    they can go through the admin. Assume that if another vendor tries to add the same item, thats
    ok, they can price compete like amazon. Maybe add a change price function for merchants to 
    change price directly...*/

    //Build the struct & push
    uint oneWei = 1000000000000000000;
    
    ourProducts[theId].merchant = msg.sender; 
    ourProducts[theId].price = thePrice*oneWei;
    ourProducts[theId].altprice = theAltPrice; 
    ourProducts[theId].stock += theStock;
    ourProducts[theId].noReserved = 0; //Start reservations at 0.
    ourProducts[theId].avail = true; 

    //Add an event to product addition 
    LogProductAddition(msg.sender, theId, thePrice, theAltPrice, theStock);
    // LogNewGlobalProduct(address shopfront, address merchant, uint price, uint altprice, uint stock);
    ShopFrontHub hub = ShopFrontHub(theHub);
    /*Assumption to only keep track of SKUs - prices and stock changes updates would need to be included */
    require(hub.newGlobalProduct(this, msg.sender, theId, thePrice, theAltPrice, theStock));
    
    return true; 
}

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
    require(howMany > 0); 
    require(ourProducts[theId].stock-ourProducts[theId].noReserved >= howMany);
    /* Requiring the purchaser to pay exact. Do not want to deal with returning 
    leftover money */
    require(msg.value == ourProducts[theId].price); 
    /* Vendor cannot buy their own product, false advertising data.*/
    require(msg.sender != ourProducts[theId].merchant);
    
    ourProducts[theId].stock -= howMany;
    
    /* Hashing the sender so they can remain 'anonymous' on the website */
    bytes32 theBuyer = keccak256(msg.sender);
    LogProductPurchased(theBuyer, theId, howMany);
    
    
    balances[admin] += msg.value*2/100;
    balances[ourProducts[theId].merchant] += msg.value*98/100; 
    /*Any remaining balances go to contract, so should do some accounting so
    that they go to the admin*/
    var anyVariance = msg.value -(msg.value*2/100)-(msg.value*98/100);
    balances[admin] += anyVariance;
    
    return true; 

}

//Function with ability to remove product.
function removeProduct(bytes32 removeId)
    onlyIfRunning
    prodAvail(removeId)
    public
    returns (bool success)

{
    /*Product should exist in the site.*/
    require(ourProducts[removeId].merchant != 0); 
    /* Only merchants or the admin should be able to remove product. */
    require(msg.sender == ourProducts[removeId].merchant || msg.sender == admin);
    /* I've seen a couple of different ways to remove, suggesting it is okay to 
    remove if numbers of events is bounded. Here you can only remove one product at a time, 
    so it should be 'bounded', right?. */
    ourProducts[removeId].avail = false; 
    /*Or I could create a variable within the struct/array that switches from 1 to 0
    based on whether or not the product should show? Maybe it's something seasonal. */
    return true; 
    /*This just leaves zeros in the mapping, is that okay?*/

}

//Function to be able to make a payment to shopfront admin.  
function makePayment() 
    onlyIfRunning
    public
    payable
    returns (bool success)
{
    balances[admin] += msg.value;
}

//Function to be able to withdrawl according to mapped balances
function withdrawl() 
    onlyIfRunning
    public
    returns (bool success)
{
   /* Only those with balanaces mapped to their addresses can withdrawl. 
   So, people that paid for "co-purchases" can withdrawl if they decide not to purchase in the end */
    require(balances[msg.sender]>0);
    var thePayment = balances[msg.sender];
    balances[msg.sender] -= thePayment;
    require(msg.sender.send(thePayment)); 
    return true; 
}

/* Co Purchasing: 
What if's & Assumptions
1. Assumptions: Only 2 people can copurchase at one time. (i.e. you can't have 3 people copurchase one thing)


/*Function to start a copurchase. Either party can create. Allows each buyer to 
pay a different amount but they have to figure it out between themselves how much
each will pay. */
function copurchasePart1(address coBuyer2, bytes32 itemId, uint amount)
    onlyIfRunning
    prodAvail(itemId)
    public
    payable
    returns (bool success)
    {
        require(msg.value > 0); 
        require(ourProducts[itemId].stock-ourProducts[itemId].noReserved >= amount); 
        require(coBuyer2 != 0x0);
        /* If they pay the whole thing, that's not a copurchase. Should use other
        functionality for buying the item on their own. */
        require(msg.value < ourProducts[itemId].price*amount); 
        combinedMoney[msg.sender][coBuyer2] += msg.value;
        itemToPurchase[msg.sender][coBuyer2] = itemId;
        ourProducts[itemId].noReserved += amount;
        //Will map their payment to a balance so if copurchase doesn't workout, then they can withdraw
        balances[msg.sender] += msg.value; 
        return true;
    }

function copurchasePart2(address coBuyer1, bytes32 itemId, uint amount)
    onlyIfRunning
    prodAvail(itemId)
    public
    payable
    returns (bool success)
    {
        require(msg.value > 0); 
        /*Since this is the second cobuyer, product should already be reserved. */
        require(ourProducts[itemId].noReserved >= amount); 
        require(coBuyer1 != 0x0); 
        require(itemToPurchase[coBuyer1][msg.sender] == itemId);
        /* Not dealing with fancy return supply chains, just pay the right amount! :) */
        if (combinedMoney[coBuyer1][msg.sender] + msg.value > ourProducts[itemId].price) throw; 
        combinedMoney[coBuyer1][msg.sender] += msg.value;
        balances[msg.sender] += msg.value;
        return true; 
    }

/* Simpifying assumption that the initiator will be the one picking up the product */
function coPickUp(address coBuyer2, bytes32 itemId, uint amount)
    onlyIfRunning
    prodAvail(itemId)
    public
    returns (bool success)
    {
        require(combinedMoney[msg.sender][coBuyer2] == ourProducts[itemId].price*amount); 
        
        require(ourProducts[itemId].stock > 0);
        ourProducts[itemId].stock -= amount; 
        ourProducts[itemId].noReserved -= amount;
        /* To Do - Think if a copurchaser makes more than one purchase at a time, 
        their balance shouldn't be zero'ed out.*/
        balances[msg.sender] = 0; 
        balances[coBuyer2] =0; 
        var anonBuyers = keccak256(msg.sender, coBuyer2);
        LogProductCoPurchased(anonBuyers, itemId, 1);
        return true;
    }

/* Function should not be payable because it is not payable in Ether */
function buyWithSFC(uint256 sfCoins, bytes32 itemId, uint howMany, address theToken)
    onlyIfRunning
    prodAvail(itemId)
    public
    returns (bool success)
    {
        BetterToken Token = BetterToken(theToken);
        require(howMany>0);
        var totalCost = ourProducts[itemId].altprice * howMany;
        require(sfCoins==totalCost);
        require(ourProducts[itemId].stock >= howMany);
        var approver = msg.sender;
        require(Token.transferFrom(approver, this, sfCoins));
        ourProducts[itemId].stock -= howMany; 
        
        bytes32 theBuyer = keccak256(msg.sender);
        LogProductPurchased(theBuyer, itemId, howMany);
    
    
        SFCbalances[admin] += sfCoins*2/100;
        SFCbalances[ourProducts[itemId].merchant] += sfCoins*98/100; 
        /*Any remaining balances go to contract, so should do some accounting so
        that they go to the admin*/
        var anyVariance = sfCoins -(sfCoins*2/100)-(sfCoins*98/100);
        SFCbalances[admin] += anyVariance;
        
        return true; 
    }


/* When I try to use the tranfer() function here, it is telling me that I have invalid arguments(?) when I wrap it in require(). */

function withdrawlSFC(address theToken)
    onlyIfRunning
    public
    returns (bool success)
{
    BetterToken Token = BetterToken(theToken);
    require(SFCbalances[msg.sender]>0);
    address payee = msg.sender; 
    uint256 thePayment = SFCbalances[msg.sender];
    SFCbalances[msg.sender] -= thePayment;
    /* For security, shouldn't the below have a require() or assert() because if I add 
    that then the contract will not compile? */
    Token.transfer(msg.sender, thePayment);
    return true;     
}

}

