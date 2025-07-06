import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("HotPotatoModule", (m) => {
  const hotPotato = m.contract("HotPotato");

  m.call(hotPotato, "createPotato", [0x0]);

  return { score: hotPotato };
});
