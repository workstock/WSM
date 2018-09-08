pragma solidity ^0.4.15;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
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

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintBurnableToken is StandardToken, Ownable {
    
  event Mint(address indexed to, uint256 amount);
  event Burn(address indexed burner, uint256 value);
  event MintFinished();

  bool public mintingFinished = false;

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }
/**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(address _burner, uint256 _value) public onlyOwner {
    require(_value <= balances[_burner]);
    balances[_burner] = balances[_burner].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Burn(_burner, _value);
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
    
    string public constant name = "Workstock.Me Token";
    
    string public constant symbol = "WSM";
    
    uint32 public constant decimals = 18;
    
}


contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    
    //Our wallets
    address public multisig;
    address public michaelAddress;
    address public antonAddress;
    address public leonidAddress;

    WSMToken public token = new WSMToken();
    mapping(address => uint) public balances;

    //Finance
    uint constant public softcap;
    uint constant public hardcap;
    uint constant public rate;
    uint public rateEthUsd;
    uint constant public restrictedTeamPercent;
    uint constant public hardcapOnPresale;
    
    // Crowdsale takes place in 6 stages (5 stages - Presale + 1 stage - Crowdsale)
    // All dates are stored as timestamps.
    uint constant public saleStartTime;
    uint constant public timePoint1;
    uint constant public timePoint2;
    uint constant public timePoint3;
    uint constant public timePoint4;
    uint constant public timePoint5;
    uint constant public saleEndTime;
    
    // Presale bonus percents
    uint constant public bonusPercent1 = 30;
    uint constant public bonusPercent2 = 25;
    uint constant public bonusPercent3 = 20;
    uint constant public bonusPercent4 = 15;
    uint constant public bonusPercent5 = 10;
    
    //Unfreeze of team tokens takes place in 6 stages (1 stage - 50%, next 5 stages - 10% every 2 months)
    // All dates are stored as timestamps.
    uint constant public startUnfreeze;
    uint constant public unfreezePoint1;
    uint constant public unfreezePoint2;
    uint constant public unfreezePoint3;
    uint constant public unfreezePoint4;
    uint constant public endUnfreeze;
    
    uint constant public unfreezePercent1;
    uint constant public unfreezePercent2;
    uint constant public unfreezePercent3;
    uint constant public unfreezePercent4;
    uint constant public unfreezePercent5;
    uint public scenario = 1;
    
    modifier saleIsOn() {
      require(now > saleStartTime && now < saleEndTime);
      _;
    }
	
    modifier isUnderHardCap() {
      require(this.balance <= hardcap);
      _;
    }
    
    function newRateEthUsd(uint _newRate) public onlyOwner {
        rateEthUsd = _newRate;
    }

    function refund() {
      require(this.balance < softcap && now > saleEndTime);
      uint value = balances[msg.sender]; 
      balances[msg.sender] = 0; 
      msg.sender.transfer(value); 
    }

    function finishMinting() public onlyOwner {
      if(this.balance > softcap) {
        multisig.transfer(this.balance);
        uint issuedTokenSupply = token.totalSupply();
        uint restrictedTokens = issuedTokenSupply.mul(restrictedTeamPercent).div(100 - restrictedTeamPercent);
        token.mint(this, restrictedTokens);
        token.finishMinting();
      }
    }

   function createTokens() isUnderHardCap saleIsOn payable {
      uint tokens = rate.mul(msg.value).div(1 ether).mul(rateEthUsd);
      uint bonusTokens = 0;
      if(now >= saleStartTime && now < timePoint1 ) {
        bonusTokens = tokens.mul(bonusPercent1).div(100);
      } else if(now >= timePoint1 && now < timePoint2) {
        bonusTokens = tokens.mul(bonusPercent2).div(100);
      } else if(now >= timePoint2 && now < timePoint3) {
        bonusTokens = tokens.mul(bonusPercent3).div(100);
      } else if(now >= timePoint3 && now < timePoint4) {
        bonusTokens = tokens.mul(bonusPercent4).div(100);
      } else if(now >= timePoint4 && now < timePoint5) {
        bonusTokens = tokens.mul(bonusPercent5).div(100);
      }
      tokens += bonusTokens;
      token.mint(msg.sender, tokens);
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }
    
    function unfreezeTeamTokens() public onlyOwner{
        if(now >= startUnfreeze && now < unfreezePoint1 && scenario == 1){
            uint unfreezeValue = restrictedTokens.mul(unfreezePercent1).div(3).div(100);
            this.transfer(antonAddress, unfreezeValue);
            this.transfer(michaelAddress, unfreezeValue);
            this.transfer(leonidAddress, unfreezeValue);
            scenario ++;
        }else(now >= unfreezePoint1 && now < unfreezePoint2 && scenario == 2){
            uint unfreezeValue = restrictedTokens.mul(unfreezePercent2).div(3).div(100);
            this.transfer(antonAddress, unfreezeValue);
            this.transfer(michaelAddress, unfreezeValue);
            this.transfer(leonidAddress, unfreezeValue);
            scenario ++;
        }else(now >= unfreezePoint2 && now < unfreezePoint3 && scenario == 3){
            uint unfreezeValue = restrictedTokens.mul(unfreezePercent3).div(3).div(100);
            this.transfer(antonAddress, unfreezeValue);
            this.transfer(michaelAddress, unfreezeValue);
            this.transfer(leonidAddress, unfreezeValue);
            scenario ++;
        }else(now >= unfreezePoint3 && now < unfreezePoint4 && scenario == 4){
            uint unfreezeValue = restrictedTokens.mul(unfreezePercent4).div(3).div(100);
            this.transfer(antonAddress, unfreezeValue);
            this.transfer(michaelAddress, unfreezeValue);
            this.transfer(leonidAddress, unfreezeValue);
            scenario ++;
        }else(now >= unfreezePoint4 && now < endUnfreeze && scenario == 5){
            uint unfreezeValue = restrictedTokens.mul(unfreezePercent5).div(3).div(100);
            this.transfer(antonAddress, unfreezeValue);
            this.transfer(michaelAddress, unfreezeValue);
            this.transfer(leonidAddress, unfreezeValue);
            scenario ++;
        }else(now >= endUnfreeze && scenario == 6){
            uint unfreezeValue = balanceOf(this).div(3);
            this.transfer(antonAddress, unfreezeValue);
            this.transfer(michaelAddress, unfreezeValue);
            this.transfer(leonidAddress, unfreezeValue);
            scenario ++;
        }
    }

    function() external payable {
      createTokens();
    }
    
}