// Generate metadata/1.json ... metadata/10000.json matching the contract's kindOf().
// Usage: npm i js-sha3 && node scripts/generate-metadata.js https://seolint.xyz/
// Then on the contract call setBaseURI("https://seolint.xyz/metadata/") from the owner wallet.
const fs = require('fs'), path = require('path');
const { keccak_256 } = require('js-sha3');
const site = (process.argv[2] || 'https://seolint.xyz/').replace(/\/?$/, '/');
const kinds = [
  [2400, 'Crawler', 'crawler.png', 'Common'],
  [4400, 'Meta Tagger', 'meta-tagger.png', 'Common'],
  [5900, 'Schema Smith', 'schema-smith.png', 'Uncommon'],
  [7200, 'Backlink Hunter', 'backlink-hunter.png', 'Uncommon'],
  [8200, 'Vitals Medic', 'vitals-medic.png', 'Rare'],
  [9100, 'Canonical Keeper', 'canonical-keeper.png', 'Rare'],
  [9700, 'Sitemap Cartographer', 'sitemap-cartographer.png', 'Epic'],
  [10000, 'Regression Sentinel', 'regression-sentinel.png', 'Legendary'],
];
// abi.encodePacked("seolint", uint256 id) -> bytes("seolint") ++ 32-byte id
function kindOf(id) {
  const buf = Buffer.concat([Buffer.from('seolint'), Buffer.from(id.toString(16).padStart(64, '0'), 'hex')]);
  const r = BigInt('0x' + keccak_256(buf)) % 10000n;
  return kinds.find(k => r < BigInt(k[0]));
}
const out = path.join(__dirname, '..', 'metadata');
fs.mkdirSync(out, { recursive: true });
for (let id = 1; id <= 10000; id++) {
  const [, name, img, rarity] = kindOf(id);
  fs.writeFileSync(path.join(out, `${id}.json`), JSON.stringify({
    name: `SEOLint Agent #${id}`,
    description: 'Pixel SEO agent of SEOLint World, minted on BNB Smart Chain.',
    image: site + img,
    attributes: [{ trait_type: 'Kind', value: name }, { trait_type: 'Rarity', value: rarity }],
  }));
}
console.log('Wrote 10,000 metadata files to /metadata');
