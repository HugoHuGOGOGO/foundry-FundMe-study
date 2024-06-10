//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant Standard_Value = 1e18;
    uint256 constant StartBalance = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, StartBalance);
    }

    function testminiumDollarisFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log("Minimum USD is: ", fundMe.MINIMUM_USD());
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
        console.log("Price feed version is: ", version);
    }

    function testfundneedrevertonnotenoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: Standard_Value}();
        _;
    }

    function testfundenoughETH() public funded {
        uint256 amountFunded = fundMe.getFundedAmount(USER);
        assertEq(amountFunded, Standard_Value);
    }

    function testFundercorrectly() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testWithdrawOnlyOwner() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdraw() public funded {
        //arrange

        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startFundMeBalance = address(fundMe).balance;

        //act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        //assert
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endFundMeBalance = address(fundMe).balance;
        assertEq(endFundMeBalance, 0);
        assertEq(endOwnerBalance, startOwnerBalance + startFundMeBalance);
    }

    function test10acountsFund() public {
        uint8 fundNumber = 10;
        uint160 fund_index = 1;
        for (fund_index; fund_index <= fundNumber; fund_index++) {
            hoax(address(fund_index), Standard_Value);
            fundMe.fund{value: Standard_Value}();
        }

        //Act
        uint256 startOwnerBalance = fundMe.getOwner().balance;
        uint256 startFundMeBalance = address(fundMe).balance;
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        uint256 endOwnerBalance = fundMe.getOwner().balance;
        uint256 endFundMeBalance = address(fundMe).balance;
        assertEq(endFundMeBalance, 0);
        assertEq(endOwnerBalance, startOwnerBalance + startFundMeBalance);
    }
}
