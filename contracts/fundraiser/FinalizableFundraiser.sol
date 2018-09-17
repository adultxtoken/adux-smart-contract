pragma solidity ^0.4.21;

import "./BasicFundraiser.sol";

/**
 * @title Finalizable Fundraiser
 *
 * @dev Allows the owner of this contract to finalize the fundraiser at any given time
 * after certain conditions are met, such as hard cap reached,
 * and also do extra work when finalized.
 */
contract FinalizableFundraiser is BasicFundraiser {
    /// Flag indicating whether or not the fundraiser is finalized.
    bool public isFinalized = false;

    /**
     * @dev Event fires if the finalization of the fundraiser is successful.
     */
    event Finalized();

    /**
     * @dev Finalizes the fundraiser. Cannot be reversed.
     */
    function finalize() onlyOwner public {
        require(!isFinalized);
        require(hasEnded());

        finalization();
        emit Finalized();

        isFinalized = true;
    }

    /**
     * @dev Override this function to add extra work when a fundraiser is finalized.
     * Don't forget to add super.finalization() to execute this part.
     */
    function finalization() internal {
        beneficiary.transfer(address(this).balance);
    }


    /**
     * @dev Do nothing, wait for finalization
     */
    function handleFunds(address, uint256) internal {
    }
    
}