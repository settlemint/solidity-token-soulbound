// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/SoulboundToken.sol";

contract SoulboundTokenTest is Test {
        function testSupportsERC165Interface() public {
        assertTrue(soulbound.supportsInterface(0x01ffc9a7));
    }

    function testName() public {
        assertEq(soulbound.name(), "Soulbound");
    }

    function testSymbol() public {
        assertEq(soulbound.symbol(), "SBT");
    }

    function testUri() public {
        assertEq(soulbound.uri(1), string(abi.encodePacked(uri, "1.json")));
    }

    function testDefaultAdminRole() public {
        assertTrue(soulbound.hasRole(DEFAULT_ADMIN_ROLE, address(this)));
    }

    function testDefaultMinterRole() public {
        soulbound.grantRole(MINTER_ROLE, address(1));
        assertTrue(soulbound.hasRole(MINTER_ROLE, address(1)));
    }

    function testSetNewUri() public {
        soulbound.setURI(newUri);
        assertEq(soulbound.uri(1), string(abi.encodePacked(newUri, "1.json")));
    }

    function testMintFunction() public {
        soulbound.grantRole(MINTER_ROLE, address(this));
        soulbound.mint(2, address(2));
        assertEq(soulbound.balanceOf(address(2), 1), 2);
        assertEq(soulbound.getCurrentTokenId(), 1);
    }

    function testPauseFunction() public {
        soulbound.pause();
        assertTrue(soulbound.paused());
    }

    function testUnpauseFunction() public {
        soulbound.pause();
        soulbound.unpause();
        assertFalse(soulbound.paused());
    }

    function testRevertPauseNotAdmin() public {
        vm.expectRevert("Caller is not an admin role authorised");
        soulbound.pause();
    }

    function testRevertUnpauseNotAdmin() public {
        soulbound.pause();
        vm.expectRevert("Caller is not an admin role authorised");
        soulbound.unpause();
    }

    function testRevertMintNotMinter() public {
        vm.expectRevert("Caller is not a minter");
        soulbound.mint(2, address(2));
    }

    function testBatchMintFunction() public {
        soulbound.grantRole(MINTER_ROLE, address(this));
        soulbound.mintBatch([2, 3, 4], address(2));
        assertEq(soulbound.balanceOf(address(2), 1), 2);
        assertEq(soulbound.balanceOf(address(2), 2), 3);
        assertEq(soulbound.balanceOf(address(2), 3), 4);
        assertEq(soulbound.getCurrentTokenId(), 3);
    }

    function testRevertBatchMintNotMinter() public {
        vm.expectRevert("Caller is not a minter");
        soulbound.mintBatch([2, 3, 4], address(2));
    }

    function testBurnFunction() public {
        soulbound.grantRole(MINTER_ROLE, address(this));
        soulbound.mint(5, address(this));
        soulbound.burn(1, 3);
        assertEq(soulbound.balanceOf(address(this), 1), 2);
    }

    function testBatchBurnFunction() public {
        soulbound.grantRole(MINTER_ROLE, address(this));
        soulbound.mintBatch([5, 10, 15], address(this));
        soulbound.burnBatch([1, 2, 3], [3, 7, 11]);
        assertEq(soulbound.balanceOf(address(this), 1), 2);
        assertEq(soulbound.balanceOf(address(this), 2), 3);
        assertEq(soulbound.balanceOf(address(this), 3), 4);
    }

    function testSetApprovalForAllFunction() public {
        soulbound.setApprovalForAll(operator, true);
        assertTrue(soulbound.isApprovedForAll(address(this), operator));
    }
}


