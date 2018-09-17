pragma solidity ^0.4.21;

import "../token/ERC20Token.sol";

contract AbstractFundraiser {
    /// The ERC20 token contract.
    ERC20Token public token;

    /**
     * @dev The event fires every time a new buyer enters the fundraiser.
     *
     * @param _address The address of the buyer.
     * @param _ethers The number of ethers funded.
     * @param _tokens The number of tokens purchased.
     */
    event FundsReceived(address indexed _address, uint _ethers, uint _tokens);


    /**
     * @dev The initialization method for the token
     *
     * @param _token The address of the token of the fundraiser
     */
    function initializeFundraiserToken(address _token) internal
    {
        token = ERC20Token(_token);
    }

    /**
     * @dev The default function which is executed when someone sends funds to this contract address.
     */
    function() public payable {
        receiveFunds(msg.sender, msg.value);
    }

    /**
     * @dev this overridable function returns the current conversion rate for the fundraiser
     */
    function getConversionRate() public view returns (uint256);

    /**
     * @dev checks whether the fundraiser passed `endTime`.
     *
     * @return whether the fundraiser has ended.
     */
    function hasEnded() public view returns (bool);

    /**
     * @dev Create and sends tokens to `_address` considering amount funded and `conversionRate`.
     *
     * @param _address The address of the receiver of tokens.
     * @param _amount The amount of received funds in ether.
     */
    function receiveFunds(address _address, uint256 _amount) internal;
    
    /**
     * @dev It throws an exception if the transaction does not meet the preconditions.
     */
    function validateTransaction() internal view;
    
    /**
     * @dev this overridable function makes and handles tokens to buyers
     */
    function handleTokens(address _address, uint256 _tokens) internal;

    /**
     * @dev this overridable function forwards the funds (if necessary) to a vault or directly to the beneficiary
     */
    function handleFunds(address _address, uint256 _ethers) internal;

}
