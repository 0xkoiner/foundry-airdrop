// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title Airdrop
 * @author 0xKoiner
 * @notice This contract is for claim airdrop tokens
 * @notice The Claimer can not initialize the TX and other user can pay gas and call `claim` function
 * @notice in this case the tokens still will be send/mint to the allowed user for airdrop
 * @dev Implements EIP712, Merkle Verification and ECDSA (public key recovery from signature)
 */
contract Airdrop is EIP712 {
    /** Usage */
    using SafeERC20 for IERC20;

    /** Errors */
    error Airdrop__MerkleProofFaild();
    error Airdrop__AlreadyClaimedTokens();
    error Airdrop__IvalidSignature();

    /** Type Declarations */
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /** States */
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account, uint256 amount)");

    address[] s_claimers;
    mapping(address account => bool ifClaimed) private s_accountsClaimed;

    /** Events */
    event TokensClaimed(address indexed _account, uint256 indexed _amount);

    /** Functions */
    /** Constructor */
    /// @param _merkleRoot Root proof of Merkle tree
    /// @param airdropToken ERC20 token of airdrop wrapped in IERC20
    /// @dev Must init constructor of EIP712
    constructor(
        bytes32 _merkleRoot,
        IERC20 airdropToken
    ) EIP712("Airdrop", "1") {
        i_merkleRoot = _merkleRoot;
        i_airdropToken = airdropToken;
    }

    /** Setters */
    function claim(
        address _account,
        uint256 _amount,
        bytes32[] calldata _merkleProof,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external {
        if (s_accountsClaimed[_account]) {
            revert Airdrop__AlreadyClaimedTokens();
        }
        if (
            !_isValidSignature(
                _account,
                getMassage(_account, _amount),
                _v,
                _r,
                _s
            )
        ) {
            revert Airdrop__IvalidSignature();
        }
        /// @dev leaf hashing twice to prevent collusions
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(_account, _amount)))
        );

        if (!MerkleProof.verify(_merkleProof, i_merkleRoot, leaf)) {
            revert Airdrop__MerkleProofFaild();
        }
        s_accountsClaimed[_account] = true;

        emit TokensClaimed(_account, _amount);

        i_airdropToken.safeTransfer(_account, _amount);
    }

    /** Getters */
    /// @param _account User who allowed to claim tokens
    /// @param _digest Hashed Message of _account and _amount
    /// @param _v Part of Signature
    /// @param _r Part of Signature
    /// @param _s Part of Signature
    /// @dev Checking if the Merkle proof is valid
    function _isValidSignature(
        address _account,
        bytes32 _digest,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) private pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(_digest, _v, _r, _s);
        return _account == actualSigner;
    }

    /// @return i_merkleRoot Return a Root hash of Merkle Tree
    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    /// @return i_airdropToken Return a Airdrop token wrappepd in IERC20
    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    /// @return _hashTypedDataV4 Return a digest message of _account & _amount
    function getMassage(
        address _account,
        uint256 _amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: _account, amount: _amount})
                    )
                )
            );
    }
}
