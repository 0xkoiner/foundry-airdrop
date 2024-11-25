// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {Airdrop} from "src/Airdrop.sol";
import {NekoToken} from "src/NekoTokenERC20.sol";

contract DeployContracts is Script {
    Airdrop airdrop;
    NekoToken nekoToken;
    bytes32 public merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    function run() public returns (Airdrop, NekoToken) {
        vm.startBroadcast();
        nekoToken = new NekoToken();
        airdrop = new Airdrop(merkleRoot, nekoToken);
        vm.stopBroadcast();

        return (airdrop, nekoToken);
    }
}
