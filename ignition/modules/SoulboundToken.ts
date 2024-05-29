import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

const SoulboundTokenModule = buildModule('SoulboundTokenModule', (m) => {
  const soulbound = m.contract('SoulboundToken', [
    'Soulbound',
    'SBT',
    'ipfs://',
  ]);

  return { soulbound };
});

export default SoulboundTokenModule;
