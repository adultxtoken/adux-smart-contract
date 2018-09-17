pragma solidity ^0.4.21;

import "../library/SafeMath.sol";
import "../token/ERC20Token.sol";


/**
 * @title TokenSafe
 *
 * @dev Abstract contract that serves as a base for the token safes. It is a multi-group token safe, where each group
 *      has it's own release time and multiple accounts with locked tokens.
 */
contract TokenSafe {
    using SafeMath for uint;

    // The ERC20 token contract.
    ERC20Token token;

    struct Group {
        // The release date for the locked tokens
        // Note: Unix timestamp fits in uint32, however block.timestamp is uint256
        uint256 releaseTimestamp;
        // The total remaining tokens in the group.
        uint256 remaining;
        // The individual account token balances in the group.
        mapping (address => uint) balances;
    }

    // The groups of locked tokens
    mapping (uint8 => Group) public groups;

    /**
     * @dev The constructor.
     *
     * @param _token The address of the Fabric Token (fundraiser) contract.
     */
    constructor(address _token) public {
        token = ERC20Token(_token);
    }

    /**
     * @dev The function initializes a group with a release date.
     *
     * @param _id Group identifying number.
     * @param _releaseTimestamp Unix timestamp of the time after which the tokens can be released
     */
    function init(uint8 _id, uint _releaseTimestamp) internal {
        require(_releaseTimestamp > 0);
        
        Group storage group = groups[_id];
        group.releaseTimestamp = _releaseTimestamp;
    }

    /**
     * @dev Add new account with locked token balance to the specified group id.
     *
     * @param _id Group identifying number.
     * @param _account The address of the account to be added.
     * @param _balance The number of tokens to be locked.
     */
    function add(uint8 _id, address _account, uint _balance) internal {
        Group storage group = groups[_id];
        group.balances[_account] = group.balances[_account].plus(_balance);
        group.remaining = group.remaining.plus(_balance);
    }

    /**
     * @dev Allows an account to be released if it meets the time constraints of the group.
     *
     * @param _id Group identifying number.
     * @param _account The address of the account to be released.
     */
    function release(uint8 _id, address _account) public {
        Group storage group = groups[_id];
        require(now >= group.releaseTimestamp);
        
        uint tokens = group.balances[_account];
        require(tokens > 0);
        
        group.balances[_account] = 0;
        group.remaining = group.remaining.minus(tokens);
        
        if (!token.transfer(_account, tokens)) {
            revert();
        }
    }
}
