pragma solidity ^0.4.21;

import "./FinalizableFundraiser.sol";
import "../component/RefundSafe.sol";

/**
 * @title Refundable fundraiser
 *
 * @dev Allows your fundraiser to offer refunds to token buyers if it failed to reach the `softCap` in its duration.
 */
contract RefundableFundraiser is FinalizableFundraiser {
    /// The minimum amount of funds (in ETH) to be gathered in order for the 
    /// fundraiser to be considered successful.
    uint256 public softCap;

    /// The instance of the refund safe which holds all ETH funds until the fundraiser
    /// is finalized.
    RefundSafe public refundSafe;

    /**
     * @dev The constructor.
     *
     * @param _softCap The minimum amount of funds (in ETH) that need to be reached.
     */
    function initializeRefundableFundraiser(uint256 _softCap) internal {
        require(_softCap > 0);

        refundSafe = new RefundSafe(address(this), beneficiary);
        softCap = _softCap;
    }

    /**
     * @dev Defines the abstract function from `BaseFundraiser` to add the funds to the `refundSafe`
     */
    function handleFunds(address _address, uint256 _ethers) internal {
        refundSafe.deposit.value(_ethers)(_address);
    }

    /**
     * @dev Checks if the soft cap was reached by the fundraiser.
     *
     * @return Whether `softCap` is reached or not.
     */
    function softCapReached() public view returns (bool) {
        return totalRaised >= softCap;
    }

    /**
     * @dev If the fundraiser failed to reach the soft cap,
     * participants can use this method to get their ether back.
     */
    function getRefund() public {
        require(isFinalized);
        require(!softCapReached());

        refundSafe.refund(msg.sender);
    }

    /**
     * @dev Overrides the setBeneficiation fucntion to set the beneficiary of the refund safe
     *
     * @param _beneficiary The address of the beneficiary.
     */
    function setBeneficiary(address _beneficiary) public onlyOwner {
        super.setBeneficiary(_beneficiary);
        refundSafe.setBeneficiary(_beneficiary);
    }

    /**
     * @dev Overrides the default function from `FinalizableFundraiser`
     * to check if soft cap was reached and appropriatelly allow refunds
     * or simply close the refund safe.
     */
    function finalization() internal {
        super.finalization();

        if (softCapReached()) {
            refundSafe.close();
        } else {
            refundSafe.allowRefunds();
        }
    }
}