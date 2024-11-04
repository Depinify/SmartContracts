//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "./interface/IAccessControl.sol";

contract Config {
    address public ACCESS_CONTROL = 0xCed9FFFCa7fB00B25b2F6CDCfBCcF2e679dfe15b;

    modifier onlyBeGrant(string memory publicKey) {
        require(
            IAccessControl(ACCESS_CONTROL).roleCheck(publicKey, msg.sender),
            "Not authorized by the account owner"
        );
        _;
    }
}
