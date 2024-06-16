//SPDX-Li

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 enterFee;
        uint256 interval;
        address vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
    }
}