//SPDX-Li

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {VRFCoordinatorV2Mock} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mock/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 enterFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64  subscriptionId;
        uint32  callbackGasLimit;
        address linkToken;
    }
    NetworkConfig public activeConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeConfig = GetSopliaEathConfg();
        } else {
            activeConfig = GetOrCreateAnvilEathConfg();
        }
    }

    function GetSopliaEathConfg() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            enterFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, // update later
            callbackGasLimit: 500000,
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function GetOrCreateAnvilEathConfg() public returns (NetworkConfig memory) {
        if (activeConfig.vrfCoordinator != address(0)) {
            return activeConfig;
        }
        uint96 baseFee = 0.1 ether; // 0.1 LINK
        uint96 gasPriceLink = 1e9; // 1 Gwei 
        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinator = new VRFCoordinatorV2Mock(baseFee, gasPriceLink);
        LinkToken linkToken = new LinkToken();
        vm.stopBroadcast();
        return NetworkConfig({
            enterFee: 0.01 ether,
            interval: 30,
            vrfCoordinator: address(vrfCoordinator),
            gasLane: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c,
            subscriptionId: 0, // update later
            callbackGasLimit: 500000,
            linkToken: address(linkToken)
        });
    }

    function getConfig() public view returns (NetworkConfig memory) {
        return activeConfig;
    }
}