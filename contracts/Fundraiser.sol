pragma solidity ^0.4.21;

import "./component/TokenSafe.sol";
import "./token/MintableToken.sol";
import "./token/BurnableToken.sol";

import "./fundraiser/MintableTokenFundraiser.sol";
import "./fundraiser/IndividualCapsFundraiser.sol";
import "./fundraiser/GasPriceLimitFundraiser.sol";
import "./fundraiser/CappedFundraiser.sol";
import "./fundraiser/RefundableFundraiser.sol";
import "./fundraiser/PresaleFundraiser.sol";

/**
 * @title AdultXToken
 */
 
contract AdultXToken is MintableToken, BurnableToken {
  constructor(address _minter)
    StandardToken(
      "Adult X Token",   // Token name
      "ADUX", // Token symbol
      18  // Token decimals
    )
    
    MintableToken(_minter)
    public
  {
  }
}


/**
 * @title AdultXTokenSafe
 */
 
contract AdultXTokenSafe is TokenSafe {
  constructor(address _token) 
    TokenSafe(_token)
    public
  {
    // Group "Team and Advisors"
    init(
      0, // Group Id
      1535716800 // Release date = 31 Aug 2018 12:00 UTC
    );
    add(
      0, // Group Id
      0x10A7201e2B59b4e37Ae34588Ed16fe2BB2013765, // Token Safe Entry Address
      50000000000000000000000000  // Allocated tokens
    );
    // Group "Marketing"
    init(
      1, // Group Id
      1535716800 // Release date = 31 Aug 2018 12:00 UTC
    );
    add(
      1, // Group Id
      0x7be89481CDd9Cd407D5A6e2c73d9c6B9B6DdfDBb, // Token Safe Entry Address
      100000000000000000000000000  // Allocated tokens
    );
    // Group "Airdrop"
    init(
      2, // Group Id
      1543665600 // Release date = 01 Dec 2018 12:00 UTC
    );
    add(
      2, // Group Id
      0xAc2582953a509804D303ad47b5E12D1bE5f3E044, // Token Safe Entry Address
      50000000000000000000000000  // Allocated tokens
    );
  }
}


/**
 * @title AdultXTokenFundraiser
 */

contract AdultXTokenFundraiser is MintableTokenFundraiser, PresaleFundraiser, IndividualCapsFundraiser, CappedFundraiser, RefundableFundraiser, GasPriceLimitFundraiser {
  AdultXTokenSafe public tokenSafe;

  constructor()
    HasOwner(msg.sender)
    public
  {
    token = new AdultXToken(
      
      address(this)  // The fundraiser is the minter
    );

    tokenSafe = new AdultXTokenSafe(token);
    MintableToken(token).mint(address(tokenSafe), 200000000000000000000000000);

    initializeBasicFundraiser(
      1540987200, // Start date = 31 Oct 2018 12:00 UTC
      1543579200,  // End date = 30 Nov 2018 12:00 UTC
      10000, // Conversion rate = 10000 ADUX per 1 ether
      0x1f98908f6857de3227fb735fACa75CCD5b9403c5     // Beneficiary
    );

    initializeIndividualCapsFundraiser(
      (0.2 ether), // Minimum contribution
      (0 ether)  // Maximum individual cap
    );

    initializeGasPriceLimitFundraiser(
        0 // Gas price limit in wei
    );

    initializePresaleFundraiser(
        50000000000000000000000000,
        1535716800, // Start =  
        1540987200,   // End = 
        14000
    );

    initializeCappedFundraiser(
      (35000 ether) // Hard cap
    );

    initializeRefundableFundraiser(
      (3500 ether)  // Soft cap
    );
    
    
  }
  
  /**
    * @dev Disable minting upon finalization
    */
  function finalization() internal {
      super.finalization();
      MintableToken(token).disableMinting();
  }
}
