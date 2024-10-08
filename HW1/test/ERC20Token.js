const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC20Token", function () {
  let token, owner, user1, user2;
  const commisonPerc = 5;
  const currentTokenId = 500;
  const tokens = 5000;

  beforeEach(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("ERC20Token");
    token = await Token.deploy(owner.address, currentTokenId, commisonPerc);
    await token.fundContract(tokens);
  });

  it("Should allow buying", async function () {
    const ethers = 1000;
    const expectedTokens = ethers / currentTokenId;
    await user1.sendTransaction({ to: owner.address, value: ethers });
    await token.connect(user1).buy({ value: ethers });
    expect(await token.balanceOf(user1.address)).to.equal(expectedTokens);
    expect(await token.balanceOf(token)).to.equal(tokens - expectedTokens);
  });

  it("Should fail if not enough tokes", async function () {
    await expect(token.connect(user1).buy({ value: 10000000000000 }))
      .to.be.revertedWith("Not enough tokens");
  });

  it("Should fail if not enough ETH send", async function () {
    await expect(token.connect(user1).buy()).to.be.revertedWith("Not enough ETH sent");
  });

  it("Should correctly transfer", async function () {
    const commision = tokens * commisonPerc / 100;
    const amountAfterFee = tokens - commision;
    await token.transfer(user1.address, tokens);
    expect(await token.balanceOf(user1.address)).to.equal(amountAfterFee);
    expect(await token.balanceOf(token)).to.equal(tokens + commision);
  });

  it("Should correctly transferFrom", async function () {
    const commision = tokens * commisonPerc / 100;
    const amountAfterFee = tokens - commision;
    await token.approve(user1.address, 100000);
    await token.connect(user1).transferFrom(owner.address, user1.address, tokens);
    expect(await token.balanceOf(user1.address)).to.equal(amountAfterFee);
    expect(await token.balanceOf(token)).to.equal(tokens + commision);
  });
});
