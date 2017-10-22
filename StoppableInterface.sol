
pragma solidity ^0.4.14; 

contract StoppableInterface{
    function Stoppable();
    function runSwitch(bool onOff) public returns (bool success);
}