// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../interfaces/IMulticall.sol";

library Context {

    bytes32 private constant _SLOT_SYSTEM_CONTEXT =
        keccak256(abi.encode("io.synthetix.synthetix.Context"));

    struct Data {
        IMulticall instance;
    }

    function load() internal pure returns (Data storage data) {
        bytes32 slot = _SLOT_SYSTEM_CONTEXT;
        assembly {
            data.slot := slot
        }
    }

    function getMessageSender() internal view returns (address sender) {  
        Data storage data = load();

        if (msg.sender == address(data.instance)) {
            address _msgSender = data.instance.getMessageSender();
            return _msgSender == address(0) ? msg.sender : _msgSender;
        }
        
        return msg.sender;
    }

    function setMulticallAddress(address _multicall) internal {
        Data storage data = load();

        data.instance = IMulticall(_multicall);
    }
}