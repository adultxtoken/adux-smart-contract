pragma solidity ^0.4.21;

import "../token/ERC20Token.sol";
import "../library/SafeMath.sol";
import "../trait/HasOwner.sol";
import "./AbstractFundraiser.sol";

/**
 * @title Basic Fundraiser
 *
 * @dev An abstract contract that is a base for fundraisers. 
 * It implements a generic procedure for handling received funds:
 * 1. Validates the transaciton preconditions
 * 2. Calculates the amount of tokens based on the conversion rate.
 * 3. Delegate the handling of the tokens (mint, transfer or conjure)
 * 4. Delegate the handling of the funds
 * 5. Emit event for received funds
 */
contract BasicFundraiser is HasOwner, AbstractFundraiser {
    using SafeMath for uint256;

    // The number of decimals for the token.
    uint8 constant DECIMALS = 18;  // Enforced

    // Decimal factor for multiplication purposes.
    uint256 constant DECIMALS_FACTOR = 10 ** uint256(DECIMALS);

    /// The start time of the fundraiser - Unix timestamp.
    uint256 public startTime;

    /// The end time of the fundraiser - Unix timestamp.
    uint256 public endTime;

    /// The address where funds collected will be sent.
    address public beneficiary;

    /// The conversion rate with decimals difference adjustment,
    /// When converion rate is lower than 1 (inversed), the function calculateTokens() should use division
    uint256 public conversionRate;

    /// The total amount of ether raised.
    uint256 public totalRaised;

    /**
     * @dev The event fires when the number of token conversion rate has changed.
     *
     * @param _conversionRate The new number of tokens per 1 ether.
     */
    event ConversionRateChanged(uint _conversionRate);

    /**
     * @dev The basic fundraiser initialization method.
     *
     * @param _startTime The start time of the fundraiser - Unix timestamp.
     * @param _endTime The end time of the fundraiser - Unix timestamp.
     * @param _conversionRate The number of tokens create for 1 ETH funded.
     * @param _beneficiary The address which will receive the funds gathered by the fundraiser.
     */
    function initializeBasicFundraiser(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _conversionRate,
        address _beneficiary
    )
        internal
    {
        require(_endTime >= _startTime);
        require(_conversionRate > 0);
        require(_beneficiary != address(0));

        startTime = _startTime;
        endTime = _endTime;
        conversionRate = _conversionRate;
        beneficiary = _beneficiary;
    }

    /**
     * @dev Sets the new conversion rate
     *
     * @param _conversionRate New conversion rate
     */
    function setConversionRate(uint256 _conversionRate) public onlyOwner {
        require(_conversionRate > 0);

        conversionRate = _conversionRate;

        emit ConversionRateChanged(_conversionRate);
    }

    /**
     * @dev Sets The beneficiary of the fundraiser.
     *
     * @param _beneficiary The address of the beneficiary.
     */
    function setBeneficiary(address _beneficiary) public onlyOwner {
        require(_beneficiary != address(0));

        beneficiary = _beneficiary;
    }

    /**
     * @dev Create and sends tokens to `_address` considering amount funded and `conversionRate`.
     *
     * @param _address The address of the receiver of tokens.
     * @param _amount The amount of received funds in ether.
     */
    function receiveFunds(address _address, uint256 _amount) internal {
        validateTransaction();

        uint256 tokens = calculateTokens(_amount);
        require(tokens > 0);

        totalRaised = totalRaised.plus(_amount);
        handleTokens(_address, tokens);
        handleFunds(_address, _amount);

        emit FundsReceived(_address, msg.value, tokens);
    }

    /**
     * @dev this overridable function returns the current conversion rate for the fundraiser
     */
    function getConversionRate() public view returns (uint256) {
        return conversionRate;
    }

    /**
     * @dev this overridable function that calculates the tokens based on the ether amount
     */
    function calculateTokens(uint256 _amount) internal view returns(uint256 tokens) {
        tokens = _amount.mul(getConversionRate());
    }

    /**
     * @dev It throws an exception if the transaction does not meet the preconditions.
     */
    function validateTransaction() internal view {
        require(msg.value != 0);
        require(now >= startTime && now < endTime);
    }

    /**
     * @dev checks whether the fundraiser passed `endtime`.
     *
     * @return whether the fundraiser is passed its deadline or not.
     */
    function hasEnded() public view returns (bool) {
        return now >= endTime;
    }
}
