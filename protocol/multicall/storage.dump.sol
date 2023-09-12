// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// @custom:artifact @synthetixio/core-contracts/contracts/context/Context.sol:Context
library Context {
    bytes32 private constant _SLOT_SYSTEM_CONTEXT = keccak256(abi.encode("io.synthetix.synthetix.Context"));
    struct Data {
        address instance;
    }
    function load() internal pure returns (Data storage data) {
        bytes32 slot = _SLOT_SYSTEM_CONTEXT;
        assembly {
            data.slot := slot
        }
    }
}

// @custom:artifact @synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol:OwnableStorage
library OwnableStorage {
    bytes32 private constant _SLOT_OWNABLE_STORAGE = keccak256(abi.encode("io.synthetix.core-contracts.Ownable"));
    struct Data {
        address owner;
        address nominatedOwner;
    }
    function load() internal pure returns (Data storage store) {
        bytes32 s = _SLOT_OWNABLE_STORAGE;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact @synthetixio/core-contracts/contracts/proxy/ProxyStorage.sol:ProxyStorage
contract ProxyStorage {
    bytes32 private constant _SLOT_PROXY_STORAGE = keccak256(abi.encode("io.synthetix.core-contracts.Proxy"));
    struct ProxyStore {
        address implementation;
        bool simulatingUpgrade;
    }
    function _proxyStore() internal pure returns (ProxyStore storage store) {
        bytes32 s = _SLOT_PROXY_STORAGE;
        assembly {
            store.slot := s
        }
    }
}

// @custom:artifact contracts/storage/Multicall.sol:Multicall
library Multicall {
    bytes32 private constant _SLOT_SYSTEM_MULTICALL = keccak256(abi.encode("io.synthetix.synthetix.Multicall"));
    struct Data {
        address msgSender;
    }
    function load() internal pure returns (Data storage data) {
        bytes32 slot = _SLOT_SYSTEM_MULTICALL;
        assembly {
            data.slot := slot
        }
    }
}
