import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';

const SoulboundTokenModule = buildModule('SoulboundTokenModule', (m) => {
  const soulbound = m.contract('Soulbound');
  m.call(soulbound, 'initialize', ['Soulbound', 'SBT', 'ipfs://']);
  return { soulbound };
});

export default SoulboundTokenModule;
