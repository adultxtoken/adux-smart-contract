pragma solidity ^0.4.21;

import "../library/SafeMath.sol";
import "../trait/HasOwner.sol";

/**
 * @title Refund Safe
 *
 * @dev Allows your fundraiser to offer refunds if soft cap is not reached 
 * while the fundraiser is active.
 */
contract RefundSafe is HasOwner {
    using SafeMath for uint256;

    /// The state of the refund safe.
    /// ACTIVE    - the default state while the fundraiser is active.
    /// REFUNDING - the refund safe allows participants in the fundraiser to get refunds.
    /// CLOSED    - the refund safe is closed for business.
    enum State {ACTIVE, REFUNDING, CLOSED}

    /// Holds all ETH deposits of participants in the fundraiser.
    mapping(address => uint256) public deposits;

    /// The address which will receive the funds if the fundraiser is successful.
    address public beneficiary;

    /// The state variable which will control the lifecycle of the refund safe.
    State public state;

    /**
     * @dev Event fired when the refund safe is closed.
     */
    event RefundsClosed();

    /**
     * @dev Event fired when refunds are allowed.
     */
    event RefundsAllowed();

    /**
     * @dev Event fired when a participant in the fundraiser is successfully refunded.
     *
     * @param _address The address of the participant.
     * @param _value The number of ETH which were refunded.
     */
    event RefundSuccessful(address indexed _address, uint256 _value);

    /**
     * @dev Constructor.
     *
     * @param _beneficiary The address which will receive the funds if the fundraiser is a success.
     */
    constructor(address _owner, address _beneficiary)
        HasOwner(_owner)
        public
    {
        require(_beneficiary != 0x0);

        beneficiary = _beneficiary;
        state = State.ACTIVE;
    }

    /**
     * @dev Sets The beneficiary address.
     *
     * @param _beneficiary The address of the beneficiary.
     */
    function setBeneficiary(address _beneficiary) public onlyOwner {
        require(_beneficiary != address(0));

        beneficiary = _beneficiary;
    }

    /**
     * @dev Deposits ETH into the refund safe.
     *
     * @param _address The address of the participant in the fundraiser.
     */
    function deposit(address _address) onlyOwner public payable {
        require(state == State.ACTIVE);

        deposits[_address] = deposits[_address].plus(msg.value);
    }

    /**
     * @dev Closes the refund safe.
     */
    function close() onlyOwner public {
        require(state == State.ACTIVE);

        state = State.CLOSED;

        emit RefundsClosed();

        beneficiary.transfer(address(this).balance);
    }

    /**
     * @dev Moves the refund safe into a state of refund.
     */
    function allowRefunds() onlyOwner public {
        require(state == State.ACTIVE);

        state = State.REFUNDING;

        emit RefundsAllowed();
    }

    /**
     * @dev Refunds a participant in the fundraiser.
     *
     * @param _address The address of the participant.
     */
    function refund(address _address) public {
        require(state == State.REFUNDING);

        uint256 amount = deposits[_address];
        // We do not want to emit RefundSuccessful events for empty accounts with zero ether
        require(amount != 0);
        // Zeroing the deposit early prevents reentrancy issues
        deposits[_address] = 0;
        _address.transfer(amount);

        emit RefundSuccessful(_address, amount);
    }
}
