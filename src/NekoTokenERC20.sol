// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ERC20 Token NEKO
 * @author 0xKoiner
 * @notice This contract is an airdrop tokens
 * @dev Implements ERC20 and Ownable
 */
contract NekoToken is ERC20, Ownable {
    /// @dev Constructor of ERC20 token
    constructor() ERC20("Neko", "NEKO") Ownable(msg.sender) {}

    /// @notice Function mint can be initialize only by Owner
    /// @param _to Account to mint the tokens
    /// @param _amount Amount of tokens to mint
    /// @dev The functions use _mint from @openzeppelin ERC20 contract
    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }
}
