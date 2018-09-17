pragma solidity ^0.4.21;

import "./BasicFundraiser.sol";
import "../token/MintableToken.sol";
import "../token/StandardMintableToken.sol";

/**
 * @title Fundraiser With Mintable Token
 */
contract MintableTokenFundraiser is BasicFundraiser {
    /**
     * @dev The initialization method that creates a new mintable token.
     *
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _decimals Token decimals
     */
    function initializeMintableTokenFundraiser(string _name, string _symbol, uint8 _decimals) internal {
        token = new StandardMintableToken(
            address(this), // The fundraiser is the token minter
            _name,
            _symbol,
            _decimals
        );
    }

    /**
     * @dev Mint the specific amount tokens
     */
    function handleTokens(address _address, uint256 _tokens) internal {
        MintableToken(token).mint(_address, _tokens);
    }
}