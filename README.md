# SEOLint Onchain Agents

10,000 pixel SEO agents minted on BNB Smart Chain.

- **Contract:** [`0x438d4b4a867cDA7e8B1F673b5db7D8C5024493E1`](https://bscscan.com/address/0x438d4b4a867cDA7e8B1F673b5db7D8C5024493E1) (BSC mainnet)
- **Mint:** 2 free per wallet (0.0003 BNB fee each), then 0.0015 BNB each, max 12 per wallet

## Files
| Path | What |
|---|---|
| `index.html` | Mint page (wallet connect via MetaMask / Trust Wallet) |
| `*.png` | Agent art + hero banner |
| `hark*.css`, `hark.js` | Page styles and helpers |
| `contracts/SEOLintAgents.sol` | Solidity source (0.8.24, OpenZeppelin v5, EVM cancun) |
| `contracts/SEOLintAgents.abi.json` | Contract ABI |
| `agents/llms.txt` | Mint instructions for AI agents |
| `scripts/generate-metadata.js` | Builds `/metadata` JSON for all 10,000 tokens |

## Publish with GitHub Pages
1. Create a repo, upload all files, commit.
2. Settings → Pages → Deploy from branch → `main` / root.
3. Site goes live at `https://seolint.xyz/` (custom domain via CNAME).

## Make NFTs show images in wallets
1. `npm i js-sha3 && node scripts/generate-metadata.js https://seolint.xyz/`
2. Commit the new `metadata/` folder.
3. From the owner wallet, call `setBaseURI("https://seolint.xyz/metadata/")` on BscScan → Contract → Write Contract.

## Owner functions
`setMintOpen(bool)`, `setPrice(wei)`, `setFreeMintFee(wei)`, `setBaseURI(string)`, `withdraw()`.

## Verify contract on BscScan
Compiler v0.8.24, optimizer on (200 runs), EVM version cancun, constructor arg `""` (empty string). Flatten the source in Remix (right-click → Flatten) before pasting.
