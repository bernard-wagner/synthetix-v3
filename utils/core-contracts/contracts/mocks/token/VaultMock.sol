//SPDX-License-Identifier: MIT
pragma solidity >=0.8.11 <0.9.0;

import "../../token/ERC20.sol";
import "../../interfaces/IERC20Permit.sol";
import "../../context/Context.sol";

contract VaultMock {
    IERC20Permit public token;

    function initialize(address _token) public payable {
        token = IERC20Permit(_token);
    }

    function depositWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable {
        token.permit(Context.getMessageSender(), address(this), amount, deadline, v, r, s);
        token.transferFrom(Context.getMessageSender(), address(this), amount);
    }
}
