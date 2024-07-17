// SPDX-LICENSE-Identifier: MIT

pragma solidity ^0.8.19;

import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {Test, console} from "lib/forge-std/src/Test.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract RaffleTest is Test {
    /* 
    EVENT 
    */
    event ParticipantEntered(address indexed participant);
    Raffle raffle;
    HelperConfig helperConfig;
    uint256 enterFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address linkToken;

    address public player = makeAddr("player");
    uint256 public INIT_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.run();
        (
            enterFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            linkToken
        ) = helperConfig.activeConfig();
        vm.deal(player, INIT_USER_BALANCE);
    }

    function testRaffleOPenState() external view {
        assertTrue(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    ////////////
    function testEnterRaffleWithNotEnoughEth() external {
        vm.prank(player);
        vm.expectRevert(Raffle.Raffle_NOT_ENOUGH_ETH.selector);
        raffle.enterRaffle();
    }

    function testRecordParticipant() external {
        vm.prank(player);
        raffle.enterRaffle{value: enterFee}();
        address playAddr = raffle.getParticipants(0);
        assertTrue(playAddr == player);
    }

    function testEnvetEmit() external {
        vm.prank(player);
        vm.expectEmit(true,false,false,false,address(raffle));
        emit ParticipantEntered(player);
        raffle.enterRaffle{value: enterFee}();
    }

    function testRaffleNotOpen() external {
        vm.prank(player);
        raffle.enterRaffle{value: enterFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle_NOT_OPEN.selector);
        vm.prank(player);
        raffle.enterRaffle{value: enterFee}();
    }
}