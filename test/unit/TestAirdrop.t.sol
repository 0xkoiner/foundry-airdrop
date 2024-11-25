// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {DeployContracts} from "script/DeployContracts.s.sol";
import {Airdrop} from "src/Airdrop.sol";
import {NekoToken} from "src/NekoTokenERC20.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract TestAirdrop is Test {
    DeployContracts deployContracts;
    Airdrop airdrop;
    NekoToken nekoToken;

    address user;
    uint256 userPrivKey;
    address gasPayer;
    bytes32 merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    bytes32[] public PROOF = [
        bytes32(
            0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a
        ),
        bytes32(
            0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576
        )
    ];

    bytes32[] public BAD_PROOF = [
        bytes32(
            0x0fd7c981d39bece61f7499702bf58b3114a90e66b51ba2c53abdf7b62986c00a
        ),
        bytes32(
            0xe5ebd1e1b5a5478a944ecab36a9a964ac3b6b8216875f6524caa7a1d87096576
        )
    ];

    uint256 constant AMOUNT = 25e18;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant MINTING_AMOUNT = AMOUNT * 10;

    /** Events */
    event TokensClaimed(address indexed _account, uint256 indexed _amount);

    function setUp() public {
        deployContracts = new DeployContracts();
        (airdrop, nekoToken) = deployContracts.run();

        vm.startPrank(msg.sender);
        nekoToken.mint(address(airdrop), MINTING_AMOUNT);
        vm.stopPrank();

        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
        console.log("user address:", user);
        console.log("private key:", userPrivKey);
        console.log("gas payer:", gasPayer);

        deal(user, STARTING_BALANCE);
        deal(gasPayer, STARTING_BALANCE);
    }

    function _getDigest(
        address _user,
        uint256 _amount
    ) private view returns (bytes32) {
        return airdrop.getMassage(_user, _amount);
    }

    function _getSignParams(
        uint256 _userPriveKey,
        bytes32 _digest
    ) private pure returns (uint8, bytes32, bytes32) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_userPriveKey, _digest);
        return (v, r, s);
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = nekoToken.balanceOf(user);
        bytes32 digest = _getDigest(user, AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = _getSignParams(userPrivKey, digest);

        vm.startPrank(user);
        airdrop.claim(user, AMOUNT, PROOF, v, r, s);
        uint256 endedBalance = nekoToken.balanceOf(user);
        vm.stopPrank();
        console.log("endind Balance: ", endedBalance);
        assertNotEq(startingBalance, endedBalance);
    }

    function testGasPayerToClaimInsteadUser() public {
        uint256 startingBalance = nekoToken.balanceOf(user);
        bytes32 digest = _getDigest(user, AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = _getSignParams(userPrivKey, digest);

        vm.startPrank(gasPayer);
        airdrop.claim(user, AMOUNT, PROOF, v, r, s);
        uint256 endedBalance = nekoToken.balanceOf(user);
        console.log("endind Balance: ", endedBalance);
        assertNotEq(startingBalance, endedBalance);
        vm.stopPrank();
    }

    function testClaimAgainAndGetReverted() public {
        bytes32 digest = _getDigest(user, AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = _getSignParams(userPrivKey, digest);

        vm.startPrank(user);
        airdrop.claim(user, AMOUNT, PROOF, v, r, s);
        vm.expectRevert(Airdrop.Airdrop__AlreadyClaimedTokens.selector);
        airdrop.claim(user, AMOUNT, PROOF, v, r, s);
        vm.stopPrank();
    }

    function testClaimRevretMerkleProofFaild() public {
        bytes32 digest = _getDigest(user, AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = _getSignParams(userPrivKey, digest);

        vm.startPrank(user);
        vm.expectRevert(Airdrop.Airdrop__MerkleProofFaild.selector);
        airdrop.claim(user, AMOUNT, BAD_PROOF, v, r, s);
        vm.stopPrank();
    }

    function testClaimRevretIvalidSignature() public {
        bytes32 digest = _getDigest(user, AMOUNT);
        (, bytes32 r, bytes32 s) = _getSignParams(userPrivKey, digest);
        uint8 v = 20;
        vm.startPrank(user);
        vm.expectRevert(Airdrop.Airdrop__IvalidSignature.selector);
        airdrop.claim(user, AMOUNT, BAD_PROOF, v, r, s);
        vm.stopPrank();
    }

    function testEmitEventCorrect() public {
        vm.expectEmit(true, true, false, true);
        emit TokensClaimed(user, AMOUNT);

        bytes32 digest = _getDigest(user, AMOUNT);
        (uint8 v, bytes32 r, bytes32 s) = _getSignParams(userPrivKey, digest);

        vm.startPrank(user);
        airdrop.claim(user, AMOUNT, PROOF, v, r, s);
        vm.stopPrank();
    }

    function testCheckGetterGetMerkleRoot() public view {
        bytes32 merkleRootGetter = airdrop.getMerkleRoot();
        assertEq(merkleRoot, merkleRootGetter);
    }

    function testCheckGetterAirdropToken() public view {
        IERC20 tokenGetter = airdrop.getAirdropToken();
        assertEq(address(tokenGetter), address(nekoToken));
    }
}
