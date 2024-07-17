// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "../lib/forge-std/src/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mock/LinkToken.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";


contract CreateSubscription is Script {
    function createSubscriptionUsingConfg() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (,,address vrfCoordinator,,,,) = helperConfig.activeConfig();
        return createSubscription(vrfCoordinator);
    }

    function createSubscription(address vrfCoordinator) public returns (uint64) {
        console.log("Creating subscription on chin %s", block.chainid);
        vm.startBroadcast();
        uint64 subID = VRFCoordinatorV2Mock(vrfCoordinator).createSubscription();
        vm.stopBroadcast();
        console.log("Subscription ID: %s", subID);
        return subID;
    }

    function run() external returns (uint64) {
        return createSubscriptionUsingConfg();
    }
}

contract FundSubscription is Script {
    uint96 public fundAmount = 3 ether;
    function fundSubscription (address _vrfCoordinator, uint64 _subId, address _linkToken) public {
        console.log("Funding subscription on chain %s , vrfCoordinator %s subId %s", block.chainid, _vrfCoordinator,_subId);
        if (block.chainid == 31337) {
            vm.startBroadcast();
            VRFCoordinatorV2Mock(_vrfCoordinator).fundSubscription(_subId, fundAmount);
            vm.stopBroadcast();
        } else {
            vm.startBroadcast();
            LinkToken(_linkToken).transferAndCall(_vrfCoordinator, fundAmount, abi.encode(_subId));
            vm.stopBroadcast();
        }
        
    }
    function fundSubscriptionUsingConfig() public  {
        HelperConfig helperConfig = new HelperConfig();
        (,,address vrfCoordinator,,uint64 subId,,address linkToken) = helperConfig.activeConfig();
        fundSubscription(vrfCoordinator, subId, linkToken);
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(address vrfCoordinator, address raffle , uint64 subId) public {
        console.log("Adding consumer on chain %s , vrfCoordinator %s subId %s", block.chainid, vrfCoordinator, subId);
        vm.startBroadcast();
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, raffle);
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        uint64 subId = helperConfig.getConfig().subscriptionId;
        address vrfCoordinatorV2_5 = helperConfig.getConfig().vrfCoordinator;
        addConsumer(vrfCoordinatorV2_5,raffle, subId);
    }


    function run() external{
        address raffle = DevOpsTools.get_most_recent_deployment("Raffle", block.chainid);
        addConsumerUsingConfig(raffle);
    }
} 

