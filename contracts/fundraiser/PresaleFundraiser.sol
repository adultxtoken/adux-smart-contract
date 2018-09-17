pragma solidity ^0.4.21;

import "./MintableTokenFundraiser.sol";

/**
 * @title PresaleFundraiser
 *
 * @dev This is the standard fundraiser contract which allows
 * you to raise ETH in exchange for your tokens.
 */
contract PresaleFundraiser is MintableTokenFundraiser {
    /// @dev The token hard cap for the pre-sale
    uint256 public presaleSupply;

    /// @dev The token hard cap for the pre-sale
    uint256 public presaleMaxSupply;

    /// @dev The start time of the pre-sale (Unix timestamp).
    uint256 public presaleStartTime;

    /// @dev The end time of the pre-sale (Unix timestamp).
    uint256 public presaleEndTime;

    /// @dev The conversion rate for the pre-sale
    uint256 public presaleConversionRate;

    /**
     * @dev The initialization method.
     *
     * @param _startTime The timestamp of the moment when the pre-sale starts
     * @param _endTime The timestamp of the moment when the pre-sale ends
     * @param _conversionRate The conversion rate during the pre-sale
     */
    function initializePresaleFundraiser(
        uint256 _presaleMaxSupply,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _conversionRate
    )
        internal
    {
        require(_endTime >= _startTime);
        require(_conversionRate > 0);

        presaleMaxSupply = _presaleMaxSupply;
        presaleStartTime = _startTime;
        presaleEndTime = _endTime;
        presaleConversionRate = _conversionRate;
    }

    /**
     * @dev Internal funciton that helps to check if the pre-sale is active
     */
    
    function isPresaleActive() internal view returns (bool) {
        return now < presaleEndTime && now >= presaleStartTime;
    }
    /**
     * @dev this function different conversion rate while in presale
     */
    function getConversionRate() public view returns (uint256) {
        if (isPresaleActive()) {
            return presaleConversionRate;
        }
        return super.getConversionRate();
    }

    /**
     * @dev It throws an exception if the transaction does not meet the preconditions.
     */
    function validateTransaction() internal view {
        require(msg.value != 0);
        require(now >= startTime && now < endTime || isPresaleActive());
    }

    function handleTokens(address _address, uint256 _tokens) internal {
        if (isPresaleActive()) {
            presaleSupply = presaleSupply.plus(_tokens);
            require(presaleSupply <= presaleMaxSupply);
        }

        super.handleTokens(_address, _tokens);
    }

}
