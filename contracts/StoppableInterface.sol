pragma solidity ^0.4.14; 

contract StoppableInterface{
    
    function runSwitch(bool onOff) public returns (bool success);
}