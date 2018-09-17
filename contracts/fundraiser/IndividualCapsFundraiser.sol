pragma solidity ^0.4.21;

import "./BasicFundraiser.sol";

/**
 * @title Fundraiser with individual caps
 *
 * @dev Allows you to set a hard cap on your fundraiser.
 */
contract IndividualCapsFundraiser is BasicFundraiser {
    uint256 public individualMinCap;
    uint256 public individualMaxCap;
    uint256 public individualMaxCapTokens;


    event IndividualMinCapChanged(uint256 _individualMinCap);
    event IndividualMaxCapTokensChanged(uint256 _individualMaxCapTokens);

    /**
     * @dev The initialization method.
     *
     * @param _individualMinCap The minimum amount of ether contribution per address.
     * @param _individualMaxCap The maximum amount of ether contribution per address.
     */
    function initializeIndividualCapsFundraiser(uint256 _individualMinCap, uint256 _individualMaxCap) internal {
        individualMinCap = _individualMinCap;
        individualMaxCap = _individualMaxCap;
        individualMaxCapTokens = _individualMaxCap * conversionRate;
    }

    function setConversionRate(uint256 _conversionRate) public onlyOwner {
        super.setConversionRate(_conversionRate);

        if (individualMaxCap == 0) {
            return;
        }
        
        individualMaxCapTokens = individualMaxCap * _conversionRate;

        emit IndividualMaxCapTokensChanged(individualMaxCapTokens);
    }

    function setIndividualMinCap(uint256 _individualMinCap) public onlyOwner {
        individualMinCap = _individualMinCap;

        emit IndividualMinCapChanged(individualMinCap);
    }

    function setIndividualMaxCap(uint256 _individualMaxCap) public onlyOwner {
        individualMaxCap = _individualMaxCap;
        individualMaxCapTokens = _individualMaxCap * conversionRate;

        emit IndividualMaxCapTokensChanged(individualMaxCapTokens);
    }

    /**
     * @dev Extends the transaction validation to check if the value this higher than the minumum cap.
     */
    function validateTransaction() internal view {
        super.validateTransaction();
        require(msg.value >= individualMinCap);
    }

    /**
     * @dev We validate the new amount doesn't surpass maximum contribution cap
     */
    function handleTokens(address _address, uint256 _tokens) internal {
        require(individualMaxCapTokens == 0 || token.balanceOf(_address).plus(_tokens) <= individualMaxCapTokens);

        super.handleTokens(_address, _tokens);
    }
}