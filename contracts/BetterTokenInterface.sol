
pragma solidity ^0.4.14;

contract BetterTokenInterface {
    function BetterToken(uint256 initialSupply, string tokenName, string tokenSymbol) public;
    function transfer(address _to, uint256 _value) public; 
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success); 
    function approve(address _spender, uint256 _value) public returns (bool success);
}
