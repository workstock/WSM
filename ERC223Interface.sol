pragma solidity ^0.4.24;

contract ERC223Interface {
    function totalSupply() external view returns (uint256);
    
    function balanceOf(address who) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transfer(address to, uint value, bytes data) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}