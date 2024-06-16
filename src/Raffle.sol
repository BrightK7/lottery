//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";


contract Raffle is VRFConsumerBaseV2{
    error Raffle_NOT_ENOUGH_ETH();
    error Raffle_TRANSFER_FAILED();
    error Raffle_INVALID_INTERVAL();
    error Raffle_NOT_OPEN();

    enum RaffleState {
        OPEN,
        CALCULATING_WINNER
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    uint256 private immutable i_enterFee;
    uint256 private immutable i_interval;
    address payable[] private i_participants;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint256 private i_lastTimeStamp;
    RaffleState private i_state;


    VRFCoordinatorV2Interface private immutable i_coordinator;
    /*EVENTS*/
    event ParticipantEntered(address indexed participant);
    event PickedWinner(address indexed winner);

    constructor(
        uint256 _enterFee, 
        uint256 interval, 
        address _vrfCoordinator, 
        bytes32 _gasLane,
        uint64 _subscriptionId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinator){
        i_enterFee = _enterFee;
        i_interval = interval;
        i_coordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_gasLane = _gasLane;
        i_subscriptionId = _subscriptionId;
        i_callbackGasLimit = _callbackGasLimit;
        i_lastTimeStamp = block.timestamp;
        i_state = RaffleState.OPEN;
     }

    function enterRaffle() external payable {
        if(msg.value != i_enterFee) {
            revert Raffle_NOT_ENOUGH_ETH();
        }
        if (i_state == RaffleState.CALCULATING_WINNER) {
            revert Raffle_NOT_OPEN();
        }
        i_participants.push(payable(msg.sender));
        emit ParticipantEntered(msg.sender);
    }

    function pickWinner() external {
        // check if the time has passed
        if (block.timestamp < (i_lastTimeStamp + i_interval)) {
            revert Raffle_INVALID_INTERVAL();
        }
        i_state = RaffleState.CALCULATING_WINNER;
        // Will revert if subscription is not set and funded.
        // Will revert if subscription is not set and funded.
        uint256 requestId = i_coordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        // pick a winner
    }


    //CEI: Check Effect Interaction
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        // check
        // effect
        // pick a winner
        uint256 winnerIndex = _randomWords[0] % i_participants.length;
        address payable winner = i_participants[winnerIndex];
        emit PickedWinner(winner);

        // reset the participants
        delete i_participants;
        i_lastTimeStamp = block.timestamp;
        i_state = RaffleState.OPEN;

        // transfer the balance to the winner
        // interation
        (bool success,) = winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle_TRANSFER_FAILED();
        }

    }
}