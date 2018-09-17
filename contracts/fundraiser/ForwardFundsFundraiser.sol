pragma solidity ^0.4.21;

import "./BasicFundraiser.sol";

/**
 * @title Forward Funds to Beneficiary Fundraiser
 *
 * @dev This contract forwards the funds received to the beneficiary.
 */
contract ForwardFundsFundraiser is BasicFundraiser {
    /**
     * @dev Forward funds directly to beneficiary
     */
    function handleFunds(address, uint256 _ethers) internal {
        // Forward the funds directly to the beneficiary
        beneficiary.transfer(_ethers);
    }
}