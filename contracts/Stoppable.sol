pragma solidity ^0.4.14; 

import "./Owned.sol";
import "./StoppableInterface.sol";
import "./OwnedInterface.sol";

contract Stoppable is Owned, StoppableInterface {
    bool    public  running; //An on/off switch that can be set by the contract holder
    
    event LogRunSwitch(address sender, bool switchSetting);
    
    modifier onlyIfRunning {require(running); _;}
     
     function Stoppable() 
     {
         running = true; 
    }
    
    function runSwitch(bool onOff) 
    public
    onlyOwner
    returns(bool success)
    {
        running = onOff; 
        LogRunSwitch(msg.sender, onOff);
        return true; 
    }
}
