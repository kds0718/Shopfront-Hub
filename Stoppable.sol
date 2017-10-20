pragma solidity ^0.4.6; 

import "./Owned.sol";

contract Stoppable is Owned {
    bool    public  running; //An on/off switch that can be set by the contract holder
    
    event LogRunSwitch(address sender, bool switchSetting);
    
    modifier onlyIfRunning {if (!running) throw; _;}
     
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
