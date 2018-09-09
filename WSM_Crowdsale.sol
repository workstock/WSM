pragma solidity ^0.4.24;

import '../Token/WSMToken.sol';
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

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
      if(now >= saleStartTime && now < timePoint1) {
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