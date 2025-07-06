import { expect } from "chai";
import { ethers } from "ethers";

describe("HotPotato", function () {
  let contract: any;
  let owner: any;
  let player1: any;
  let player2: any;
  let player3: any;
  let player4: any;
  let player5: any;
  let player6: any;

  beforeEach(async () => {
    [owner, player1, player2, player3, player4, player5, player6] = await ethers.getSigners();
    const HotPotatoFactory = await ethers.getContractFactory("HotPotato");
    contract = await HotPotatoFactory.deploy();
  });

  it("is owner", async () => {
    expect(await contract.owner()).to.equal(owner.address);
  });

  it("should create a potato", async () => {
    await contract.createPotato(player1.address);
    const holder = await contract.getPotatoHolder(1);
    expect(holder).to.equal(player1.address);
  });

  it("should pass the potato and update recent holders", async () => {
    await contract.createPotato(player1.address);
    await contract.passPotato(1, player2.address);
    await contract.passPotato(1, player3.address);
    const holder = await contract.getPotatoHolder(1);
    expect(holder).to.equal(player3.address);
  });

  it("should not allow passing potato to someone in recent holders", async () => {
    await contract.createPotato(player1.address);
    await contract.passPotato(1, player2.address);
    await contract.passPotato(1, player3.address);
    await contract.passPotato(1, player4.address);
    await contract.passPotato(1, player5.address);
    await contract.passPotato(1, player6.address);
    await expect(contract.passPotato(1, player2.address)).to.be.revertedWith("Recipient is in recent holders");
  });

  it("should burn and reward score correctly", async () => {
    await contract.createPotato(player1.address);
    await contract.passPotato(1, player2.address);
    await contract.passPotato(1, player3.address);
    await contract.passPotato(1, player4.address);

    await ethers.provider.send("evm_increaseTime", [600]);
    await ethers.provider.send("evm_mine", []);

    await contract.connect(player4).burnPotato(1);

    const score1 = await contract.getScore(player1.address);
    const score2 = await contract.getScore(player2.address);
    const score3 = await contract.getScore(player3.address);

    expect(score1).to.equal(2);
    expect(score2).to.equal(1);
    expect(score3).to.equal(0);
  });
});
