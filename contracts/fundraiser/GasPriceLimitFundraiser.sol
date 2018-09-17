pragma solidity ^0.4.21;

import "./BasicFundraiser.sol";

/**
 * @title GasPriceLimitFundraiser
 *
 * @dev This fundraiser allows to set gas price limit for the participants in the fundraiser
 */
contract GasPriceLimitFundraiser is HasOwner, BasicFundraiser {
    uint256 public gasPriceLimit;

    event GasPriceLimitChanged(uint256 gasPriceLimit);

    /**
     * @dev This function puts the initial gas limit
     */
    function initializeGasPriceLimitFundraiser(uint256 _gasPriceLimit) internal {
        gasPriceLimit = _gasPriceLimit;
    }

    /**
     * @dev This function allows the owner to change the gas limit any time during the fundraiser
     */
    function changeGasPriceLimit(uint256 _gasPriceLimit) onlyOwner() public {
        gasPriceLimit = _gasPriceLimit;

        emit GasPriceLimitChanged(_gasPriceLimit);
    }

    /**
     * @dev The transaction is valid if the gas price limit is lifted-off or the transaction meets the requirement
     */
    function validateTransaction() internal view {
        require(gasPriceLimit == 0 || tx.gasprice <= gasPriceLimit);

        return super.validateTransaction();
    }
}