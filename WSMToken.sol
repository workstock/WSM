pragma solidity ^0.4.24;

import "https://github.com/workstock/WSM/ERC223.sol";
import "https://github.com/workstock/WSM/ERC223Mintable.sol";
import "https://github.com/workstock/WSM/ERC223Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title Reference implementation of the ERC223 standard token.
 */
contract WSMToken is ERC223, Ownable, ERC223Mintable, ERC223Burnable  {

    string public name;
    string public symbol;
    uint8 public decimals;
    
    // Function to access name of token .
    function name() public view returns (string _name) {
        return name;
    }
    
    // Function to access symbol of token .
    function symbol() public view returns (string _symbol) {
        return symbol;
    }
    
    // Function to access decimals of token .
    function decimals() public view returns (uint8 _decimals) {
        return decimals;
    }

}