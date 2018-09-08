pragma solidity ^0.4.16;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

}

contract MintBurnableToken is StandardToken, Ownable {

  event Burn(address indexed burner, uint256 value);
  event Mint(address indexed minter, uint256 value);
  event MintFinished();
  
  bool public mintingFinished = false;
  uint public finishSupply;
  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(address _burner, uint256 _value) public onlyOwner {
    require(_value <= balances[burner]);
    balances[burner] = balances[burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(burner, _value);
  }

  /**
   * @dev Function to mint tokens
   * @param _minter The address that will recieve the minted tokens.
   * @param _value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _minter, uint256 _value) public onlyOwner {
    require(!mintingFinished);
    totalSupply = totalSupply.add(_value);
    balances[_to] = balances[_to].add(_value);
    Mint(_to, _value);
  }
 
  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract WSMToken is MintBurnableToken {

  string public name = "WorkStock Token";
  string public symbol = "WSM";
  uint8 public decimals = 18;
  
  uint256 public constant FINISH_SUPPLY = 4600000 * (10 ** uint256(decimals));
  
  function WSMToken() {
    totalSupply = 0;
    finishSupply = 2300000 * (10 ** 18);
    balances[msg.sender] = 0;
  }

}

contract WSMCrowdsale is Ownable {
    using SafeMath for uint256;

    address public investWallet;
    address public restricted;
    WSMToken public tokenReward = new WSMToken();

    uint256 public softcap;
    uint256 public hardcap;
    uint256 public tokenPriceETH;
    uint256 public minimalETH;
    uint256 public start;
    uint256 public preSalePeriod;
    uint256 public salePeriod;
    uint256 public restrictedPercent;

    mapping(address => uint) public balances;
    
    function WSMCrowdsale() {
        investWallet = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
        restricted = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        softcap = 10 * 1 ether;
        hardcap = 100 * 1 ether;
        tokenPriceETH = 10 ** 14;
        minimalETH = 10 ** 18;
        start = 1532456435;
        preSalePeriod = 1 * 1 minutes;
        period = 20 * 1 minutes;
        restrictedPercent = 50;
    }
    modifier saleIsOn() {
      require(now > start && now < start + salePeriod);
      _;
    }
    
    modifier isUnderHardCap() {
      require(investWallet.balance <= hardcap);
      _;
    }
    function () payable {
        createTokens();
    }

    function buy(address buyer) payable {
        require(buyer != address(0));
        require(msg.value != 0);
        require(msg.value >= minimalETH);

        uint amount = msg.value;
        uint tokens = amount.div(tokenPriceETH);
        tokenReward.mint(buyer, tokens);
        investWallet.transfer(this.balance);
    }
    
    function createTokens() isUnderHardCap saleIsOn payable {
        require(msg.value != 0);
        require(msg.value >= minimalETH)
      uint tokens = (msg.value).div(tokenPriceETH).mul(10**18);
      uint bonusTokens = 0;
      if(now < start + (preSalePeriod)) {
        bonusTokens = tokens.mul(3).div(10);
      } else if(now >= start + (preSalePeriod) && now < start + (preSalePeriod).mul(2)) {
        bonusTokens = tokens.div(4);
      } else if(now >= start + (preSalePeriod).mul(2) && now < start + (preSalePeriod).mul(3)) {
        bonusTokens = tokens.div(5);
      } else if(now >= start + (preSalePeriod).mul(3) && now < start + (preSalePeriod).mul(4)) {
        bonusTokens = tokens.mul(3).div(20);  
      } else if(now >= start + (preSalePeriod).mul(4) && now < start + (preSalePeriod).mul(5)) {
        bonusTokens = tokens.div(10);  
      }
      tokens += bonusTokens;
      tokenReward.mint(msg.sender, tokens);
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }


}

