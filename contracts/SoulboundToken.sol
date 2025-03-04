// SPDX-License-Identifier: FSL-1.1-MIT
// SettleMint.com

pragma solidity ^0.8.24;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import {
    ERC1155SupplyUpgradeable,
    ERC1155Upgradeable
} from "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable, Initializable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

contract Soulbound is
    Initializable,
    UUPSUpgradeable,
    ERC1155SupplyUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable
{
    using Strings for uint256;
    //using CountersUpgradeable for CountersUpgradeable.Counter;

    uint256 _tokenIdCounter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    string public name;
    string public symbol;

    function initialize(string memory name_, string memory symbol_, string memory uri_) external initializer {
        __ERC1155_init(uri_);
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        name = name_;
        symbol = symbol_;
    }

    function _update(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    )
        internal
        override(ERC1155SupplyUpgradeable)
    {
        require(from == address(0) || to == address(0), "A Soulbound token cannot be transferred");
        super._update(from, to, ids, values);
    }

    function getCurrentTokenId() external view returns (uint256) {
        return _tokenIdCounter;
    }

    function pause() public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin role authorised");
        _pause();
    }

    function unpause() public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin role authorised");
        _unpause();
    }

    function mint(uint256 amounts, address recipient) external {
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        _tokenIdCounter++;
        _mint(recipient, _tokenIdCounter, amounts, "");
    }

    function mintBatch(uint256[] memory amounts, address recipient) public {
        uint256[] memory tokenIdsArray = new uint256[](amounts.length);
        require(hasRole(MINTER_ROLE, msg.sender), "Caller is not a minter");
        for (uint256 i = 0; i < amounts.length; ++i) {
            _tokenIdCounter++;
            uint256 tokenId = _tokenIdCounter;
            tokenIdsArray[i] = tokenId;
        }
        _mintBatch(recipient, tokenIdsArray, amounts, "");
    }

    function burn(uint256 tokenId, uint256 amounts) external {
        _burn(msg.sender, tokenId, amounts);
    }

    function burnBatch(uint256[] memory tokenIds, uint256[] memory amounts) external {
        _burnBatch(msg.sender, tokenIds, amounts);
    }

    function setURI(string memory newuri) external {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not an admin role authorised");
        _setURI(newuri);
    }

    function uri(uint256 id) public view override returns (string memory) {
        return string(abi.encodePacked(super.uri(id), id.toString(), ".json"));
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return interfaceId == type(OwnableUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */
    function _authorizeUpgrade(address newImplementation) internal override { }
}
