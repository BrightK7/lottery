//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract DeployRaffle is Script {
    function run(
        uint256 _enterFee, 
        uint256 interval, 
        address _vrfCoordinator, 
        bytes32 _gasLane,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) external returns (Raffle raffle) {
        Raffle raffle = new Raffle(
            _enterFee, 
            interval, 
            _vrfCoordinator, 
            _gasLane,
            _subscriptionId,
            _callbackGasLimit
        );
        vm.startBroadcast();
        vm.stopBroadcast();
    }
}