// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./HotPotato.sol";

contract HotPotatoTest is Test {
    HotPotato public potato;
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public carol = address(0x3);
    address public deployer;

    function setUp() public {
        deployer = address(this);
        potato = new HotPotato();
    }

    function testCreatePotato() public {
        uint256 id = potato.createPotato(alice);
        assertEq(id, 1);
        assertEq(potato.getPotatoHolder(1), alice);
        assertTrue(potato.isActive(1));
    }

    function testPassPotato() public {
        uint256 id = potato.createPotato(alice);

        vm.warp(block.timestamp + 1);
        potato.passPotato(id, bob);
        assertEq(potato.getPotatoHolder(id), bob);
        assertTrue(potato.isActive(id));
    }

    function testRecentHoldersReject() public {
        uint256 id = potato.createPotato(alice);

        vm.warp(block.timestamp + 1);
        potato.passPotato(id, bob);
        vm.warp(block.timestamp + 1);
        potato.passPotato(id, carol);
        vm.warp(block.timestamp + 1);

        vm.expectRevert("Recipient is in recent holders");
        potato.passPotato(id, alice);
    }

    function testBurnPotatoAndScore() public {
        uint256 id = potato.createPotato(alice);
        vm.warp(block.timestamp + 1);
        potato.passPotato(id, bob);
        vm.warp(block.timestamp + 1);
        potato.passPotato(id, carol);

        vm.warp(block.timestamp + 601);
        potato.burnPotato(id);

        assertEq(potato.getScore(alice), 1); // position 0
        assertEq(potato.getScore(bob), 0);   // position 1, no score. He had to encourage the next person to pass the potato
        assertEq(potato.getScore(carol), 0); // current holder of an expired potato
    }

    function testBurnFailsBeforeTime() public {
        uint256 id = potato.createPotato(alice);
        vm.warp(block.timestamp + 1);
        potato.passPotato(id, bob);
        vm.expectRevert("Still within time");
        potato.burnPotato(id);
    }

    function testGetTimeLeft() public {
        uint256 id = potato.createPotato(alice);
        uint256 timeLeft = potato.getTimeLeft(id);
        assertEq(timeLeft, 600);
        vm.warp(block.timestamp + 100);
        assertEq(potato.getTimeLeft(id), 500);
        vm.warp(block.timestamp + 600);
        assertEq(potato.getTimeLeft(id), 0);
    }
}
