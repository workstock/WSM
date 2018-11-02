pragma solidity ^0.4.24;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "https://github.com/workstock/WSM/Crowdsale/TimedCrowdsale.sol";

contract IncreasingPriceCrowdsale is TimedCrowdsale {
  using SafeMath for uint256;
  
  uint256[] _ratePoints;

  constructor(uint256[] ratePoints) public {
    super._checkArray(ratePoints);
    require(ratePoints.length == _timePoints.length-1);
    _ratePoints = ratePoints;
  }
  
  /**
   * @dev Returns the rate of tokens per wei at the present time.
   * Note that, as price _increases_ with time, the rate _decreases_.
   * @return The number of tokens a buyer gets per wei at a given time
   */
  function getCurrentRate() public view returns (uint256) {
    // solium-disable-next-line security/no-block-members
    uint256 rate;
    for (uint i = 0; i < _timePoints.length-1; i++){
        if (_timePoints[i] < block.timestamp && block.timestamp < _timePoints[i+1]){
            rate = _ratePoints[i];
        }
    }
    return rate;
  }

  /**
   * @dev Overrides parent method taking into account variable rate.
   * @param weiAmount The value in wei to be converted into tokens
   * @return The number of tokens _weiAmount wei will buy at present time
   */
  function _getTokenAmount(uint256 weiAmount) internal view returns (uint256){
    uint256 currentRate = getCurrentRate();
    return currentRate.mul(weiAmount);
  }

}
