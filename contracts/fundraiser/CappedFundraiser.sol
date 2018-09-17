pragma solidity ^0.4.21;

import "./BasicFundraiser.sol";

/**
 * @title Capped Fundraiser
 *
 * @dev Allows you to set a hard cap on your fundraiser.
 */
contract CappedFundraiser is BasicFundraiser {
    /// The maximum amount of ether allowed for the fundraiser.
    uint256 public hardCap;

    /**
     * @dev The initialization method.
     *
     * @param _hardCap The maximum amount of ether allowed to be raised.
     */
    function initializeCappedFundraiser(uint256 _hardCap) internal {
        require(_hardCap > 0);

        hardCap = _hardCap;
    }

    /**
     * @dev Adds additional check if the hard cap has been reached.
     *
     * @return Whether the token purchase will be allowed.
     */
    function validateTransaction() internal view {
        super.validateTransaction();
        require(totalRaised < hardCap);
    }

    /**
     * @dev Overrides the method from the default `Fundraiser` contract
     * to additionally check if the `hardCap` is reached.
     *
     * @return Whether or not the fundraiser has ended.
     */
    function hasEnded() public view returns (bool) {
        return (super.hasEnded() || totalRaised >= hardCap);
    }
}