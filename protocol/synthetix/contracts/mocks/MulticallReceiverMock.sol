//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "@synthetixio/core-contracts/contracts/interfaces/IMulticall.sol";

contract MulticallReceiverMock {
    event MessageSenderTested(address indexed sender);

    function testMessageSender() external payable returns (address) {
        emit MessageSenderTested(IMulticall(msg.sender).getMessageSender());
        return msg.sender;
    }
}
