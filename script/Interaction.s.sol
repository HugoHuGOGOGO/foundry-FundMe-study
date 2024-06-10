//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlydeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlydeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract with ", SEND_VALUE, "ETH");
    }

    function run() external {
        address mostRecentlydeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();

        fundFundMe(mostRecentlydeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlydeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlydeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlydeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        //vm.startBroadcast();
        withdrawFundMe(mostRecentlydeployed);
        //vm.stopBroadcast();
    }
}
