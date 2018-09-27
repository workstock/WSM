pragma solidity ^0.4.24;
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol"
/**
 * @title CappedCrowdsale
 * @dev Crowdsale with a limit for total contributions.
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 private _hardcap;
  uint256 private _softcap

  /**
   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.
   * @param cap Max amount of wei to be contributed
   */
  constructor(uint256 softcap, uint256 hardcap) public {
    require(cap > 0);
    require(softcap < hardcap);
    _softcap = softcap;
    _hardcap = hardcap;
  }

  /**
   * @return the cap of the crowdsale.
   */
  function softcap() public view returns(uint256) {
    return _softcap;
  }
  
  function hardcap() public view returns(uint256) {
    return _hardcap;
  }

  /**
   * @dev Checks whether the cap has been reached.
   * @return Whether the cap was reached
   */
  function softcapReached() public view returns (bool) {
    return weiRaised() >= _softcap;
  }
  function hardcapReached() public view returns (bool) {
    return weiRaised() >= _hardcap;
  }

  /**
   * @dev Extend parent behavior requiring purchase to respect the funding cap.
   * @param beneficiary Token purchaser
   * @param weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
  {
    super._preValidatePurchase(beneficiary, weiAmount);
    require(weiRaised().add(weiAmount) <= _hardcap);
  }

}
