//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "../lib/forge-std/src/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interaction.s.sol";

contract DeployRaffle is Script {
    function run () external returns (Raffle, HelperConfig){
        HelperConfig helperConfig = new HelperConfig();
        (
            uint256 enterFee,
            uint256 interval,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address linkToken
        ) = helperConfig.activeConfig();

        if (subscriptionId == 0) {
            // we need to create a new subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinator);

            // Fund it
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(vrfCoordinator, subscriptionId, linkToken);

        }

        vm.startBroadcast();
        Raffle raffle = new Raffle(
            enterFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();

        //Add consumer
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(vrfCoordinator, address(raffle), subscriptionId);

        return (raffle, helperConfig);
    }
}