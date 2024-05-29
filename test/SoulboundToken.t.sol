// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Test, console} from "forge-std/Test.sol";
import {Soulbound} from "../contracts/SoulboundToken.sol";

contract SoulboundTokenTest is Test {
    Soulbound soulbound;
    address operator = address(0x123);
    string uri = "https://example.com/metadata/";
    string newUri = "https://example.com/new-metadata/";

    function setUp() public {
        // Deploy and initialize the Soulbound contract
        soulbound = new Soulbound();
        soulbound.initialize("Soulbound", "SBT", uri);
        soulbound.grantRole(soulbound.DEFAULT_ADMIN_ROLE(), address(this));
    }

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
        assertTrue(
            soulbound.hasRole(soulbound.DEFAULT_ADMIN_ROLE(), address(this))
        );
    }

    function testDefaultMinterRole() public {
        soulbound.grantRole(soulbound.MINTER_ROLE(), address(1));
        assertTrue(soulbound.hasRole(soulbound.MINTER_ROLE(), address(1)));
    }

    function testSetNewUri() public {
        soulbound.setURI(newUri);
        assertEq(soulbound.uri(1), string(abi.encodePacked(newUri, "1.json")));
    }

    function testMintFunction() public {
        soulbound.grantRole(soulbound.MINTER_ROLE(), address(this));
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
        vm.prank(address(1));
        vm.expectRevert("Caller is not an admin role authorised");
        soulbound.pause();
    }

    function testRevertUnpauseNotAdmin() public {
        soulbound.pause();
        vm.prank(address(1));
        vm.expectRevert("Caller is not an admin role authorised");
        soulbound.unpause();
    }

    function testRevertMintNotMinter() public {
        vm.expectRevert("Caller is not a minter");
        soulbound.mint(2, address(2));
    }

    function testMintBatch() public {
        soulbound.grantRole(soulbound.MINTER_ROLE(), address(this));
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 2;
        amounts[1] = 3;
        amounts[2] = 4;
        soulbound.mintBatch(amounts, address(2));
        assertEq(soulbound.balanceOf(address(2), 1), 2);
        assertEq(soulbound.balanceOf(address(2), 2), 3);
        assertEq(soulbound.balanceOf(address(2), 3), 4);
    }

    function testBurnBatch() public {
        soulbound.grantRole(soulbound.MINTER_ROLE(), address(this));

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 1;
        tokenIds[1] = 2;
        tokenIds[2] = 3;

        // Mint some tokens first
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 2;
        amounts[1] = 3;
        amounts[2] = 4;
        soulbound.mintBatch(amounts, address(2));

        // Verify balances before burning
        assertEq(soulbound.balanceOf(address(2), 1), 2);
        assertEq(soulbound.balanceOf(address(2), 2), 3);
        assertEq(soulbound.balanceOf(address(2), 3), 4);

        // Burn the tokens
        vm.prank(address(2));
        soulbound.burnBatch(tokenIds, amounts);

        // Verify balances after burning
        assertEq(soulbound.balanceOf(address(2), 1), 0);
        assertEq(soulbound.balanceOf(address(2), 2), 0);
        assertEq(soulbound.balanceOf(address(2), 3), 0);
    }
}
