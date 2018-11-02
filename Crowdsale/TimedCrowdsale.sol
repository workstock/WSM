pragma solidity ^0.4.24;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "https://github.com/workstock/WSM/Crowdsale/Crowdsale.sol";

contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public _openingTime;
  uint256 public _closingTime;
  
  uint256[] public _timePoints;
  
    function _checkArray(uint256[] array) internal pure returns(bool) {
        bool flag = true;
        for (uint8 i = 0; i<array.length-1; i++){
            if(array[i] > array[i+1]){
                flag = false;
            }
        }
        return flag;
    }

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    require(isOpen());
    _;
  }

  constructor(uint256[] timePoints) public {
    // solium-disable-next-line security/no-block-members
    require(_checkArray(timePoints));
    _timePoints = timePoints;
    _openingTime = _timePoints[0];
    _closingTime = _timePoints[_timePoints.length-1];
  }

  /**
   * @return the crowdsale opening time.
   */
  function openingTime() public view returns(uint256) {
    return _openingTime;
  }

  /**
   * @return the crowdsale closing time.
   */
  function closingTime() public view returns(uint256) {
    return _closingTime;
  }

  /**
   * @return true if the crowdsale is open, false otherwise.
   */
  function isOpen() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > _closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param beneficiary Token purchaser
   * @param weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view onlyWhileOpen {
    super._preValidatePurchase(beneficiary, weiAmount);
  }

}
