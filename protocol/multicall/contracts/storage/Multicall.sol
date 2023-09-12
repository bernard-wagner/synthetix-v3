// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Multicall {

    bytes32 private constant _SLOT_SYSTEM_MULTICALL =
        keccak256(abi.encode("io.synthetix.synthetix.Multicall"));

    struct Data {
        address msgSender;
    }

    function load() internal pure returns (Data storage data) {
        bytes32 slot = _SLOT_SYSTEM_MULTICALL;
        assembly {
            data.slot := slot
        }
    }

    function msgSender() internal view returns (address sender) {   
        if (msg.sender == address(this)) {
            Data storage data = load();
            address _msgSender = data.msgSender;
            return _msgSender == address(0) ? msg.sender : _msgSender;
        }
        
        return msg.sender;
    }

}