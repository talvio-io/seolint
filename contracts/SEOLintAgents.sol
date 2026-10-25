// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
  SEOLint Onchain Agents — ERC-721 on BNB Chain
  - 10,000 max supply
  - 2 free mints per wallet (pay only a small fee: 0.0003 BNB each)
  - After that, paid mint at `price` (default 0.0015 BNB, owner can change)
  - 12 per wallet max
  - Owner can open/close mint, set prices, set metadata URI, withdraw
  Deploy with Remix (remix.ethereum.org) + MetaMask on BNB Smart Chain.
*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SEOLintAgents is ERC721, Ownable, ReentrancyGuard {
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 public constant FREE_PER_WALLET = 2;
    uint256 public constant MAX_PER_WALLET = 12;

    uint256 public freeMintFee = 0.0003 ether; // BNB per free mint
    uint256 public price = 0.0015 ether;       // BNB per paid mint (~$1, adjust)
    bool public mintOpen = false;

    uint256 public totalSupply;
    string private baseURI;

    mapping(address => uint256) public mintedBy;

    event Minted(address indexed to, uint256 quantity, uint256 freeCount, uint256 paid);

    constructor(string memory initialBaseURI)
        ERC721("SEOLint Onchain Agents", "SEOAGENT")
        Ownable(msg.sender)
    {
        baseURI = initialBaseURI;
    }

    /// How many of the next `quantity` mints are free for `wallet`.
    function freeLeft(address wallet) public view returns (uint256) {
        uint256 m = mintedBy[wallet];
        return m >= FREE_PER_WALLET ? 0 : FREE_PER_WALLET - m;
    }

    /// Total BNB `wallet` must send to mint `quantity`.
    function quote(address wallet, uint256 quantity) public view returns (uint256) {
        uint256 f = freeLeft(wallet);
        uint256 freeCount = quantity < f ? quantity : f;
        uint256 paidCount = quantity - freeCount;
        return freeCount * freeMintFee + paidCount * price;
    }

    function mint(uint256 quantity) external payable nonReentrant {
        require(mintOpen, "Mint closed");
        require(quantity > 0, "Zero quantity");
        require(totalSupply + quantity <= MAX_SUPPLY, "Sold out");
        require(mintedBy[msg.sender] + quantity <= MAX_PER_WALLET, "Wallet limit");

        uint256 cost = quote(msg.sender, quantity);
        require(msg.value >= cost, "Not enough BNB");

        uint256 f = freeLeft(msg.sender);
        uint256 freeCount = quantity < f ? quantity : f;

        mintedBy[msg.sender] += quantity;
        for (uint256 i = 0; i < quantity; i++) {
            totalSupply++;
            _safeMint(msg.sender, totalSupply); // token ids 1..10000
        }

        // refund overpayment
        if (msg.value > cost) {
            (bool ok, ) = payable(msg.sender).call{value: msg.value - cost}("");
            require(ok, "Refund failed");
        }
        emit Minted(msg.sender, quantity, freeCount, cost);
    }

    /// Kind is fixed per token id by hash; odds match supply targets 24/20/15/13/10/9/6/3 %.
    function kindOf(uint256 tokenId) public pure returns (string memory) {
        require(tokenId >= 1 && tokenId <= MAX_SUPPLY, "Bad id");
        uint256 r = uint256(keccak256(abi.encodePacked("seolint", tokenId))) % 10_000;
        if (r < 2400) return "Crawler";
        if (r < 4400) return "Meta Tagger";
        if (r < 5900) return "Schema Smith";
        if (r < 7200) return "Backlink Hunter";
        if (r < 8200) return "Vitals Medic";
        if (r < 9100) return "Canonical Keeper";
        if (r < 9700) return "Sitemap Cartographer";
        return "Regression Sentinel";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    // ---------- owner ----------
    function setMintOpen(bool open) external onlyOwner { mintOpen = open; }
    function setFreeMintFee(uint256 fee) external onlyOwner { freeMintFee = fee; }
    function setPrice(uint256 p) external onlyOwner { price = p; }
    function setBaseURI(string calldata uri) external onlyOwner { baseURI = uri; }

    function withdraw() external onlyOwner {
        (bool ok, ) = payable(owner()).call{value: address(this).balance}("");
        require(ok, "Withdraw failed");
    }
}
