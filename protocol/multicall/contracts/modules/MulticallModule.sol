//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import {IMulticall} from "@synthetixio/core-contracts/contracts/interfaces/IMulticall.sol";


import {OwnableStorage} from "@synthetixio/core-contracts/contracts/ownership/OwnableStorage.sol";
import {ParameterError} from "@synthetixio/core-contracts/contracts/errors/ParameterError.sol";
import "../storage/Multicall.sol";

/**
 * @title Module that enables calling multiple methods of the system in a single transaction.
 * @dev See IMulticallModule.
 * @dev Implementation adapted from https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/Multicall.sol
 */
contract MulticallModule is IMulticall {


    /**
     * @inheritdoc IMulticall
     */
    function multicallThrough(
        address[] calldata to,
        bytes[] calldata data,
        uint256[] calldata value
    ) public payable override returns (bytes[] memory results) {
        if (to.length != data.length || to.length != value.length) {
            revert ParameterError.InvalidParameter("", "all arrays must be same length");
        }
        
        Multicall.Data storage multicall_ = Multicall.load();
        if (multicall_.msgSender != address(0)) {
            revert RecursiveMulticall(multicall_.msgSender);
        }

        multicall_.msgSender = msg.sender;

 

        bool success;
        bytes memory result;
        results = new bytes[](data.length);

        for (uint256 i = 0; i < data.length; i++) {            
            (success, result) = address(to[i]).call{value: value[i]}(data[i]);
            if (!success) {
                uint len = result.length;
                assembly {
                    revert(add(result, 0x20), len)
                }
            }

            results[i] = result;
        }

        multicall_.msgSender = address(0);
    }

    /**
     * @inheritdoc IMulticall
     */
    function getMessageSender() external view override returns (address) {
        return  Multicall.load().msgSender;
    }
}
