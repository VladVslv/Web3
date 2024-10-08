const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC1155Token Contract", function () {
  let token;
  let owner;
  let user1;
  let user2;
  const currentTokenId = 1;
  const tokenId = 0;
  const NFTId = 1;

  beforeEach(async function () {
    [owner, user1, user2, ...otherAddresses] = await ethers.getSigners();
    token = await (await ethers.getContractFactory("ERC1155Token")).deploy(owner.address, currentTokenId);
  });

  it("Should initialize the contract with the correct owner", async function () {
    expect(await token.owner()).to.equal(owner.address);
  });

  it("Should mint initial tokens to the contract address", async function () {
    const contractTokenBalance = await token.balanceOf(token, tokenId);
    expect(contractTokenBalance).to.equal(1000000000000000000n);
  });

  it("Should allow buying fungible tokens by sending Ether", async function () {
    const buyAmount = 10;
    const totalPrice = currentTokenId * buyAmount;
    await expect(
      token.connect(user1).purchaseTokens(user1.address, buyAmount, { value: totalPrice })
    )
      .to.emit(token, "TransferSingle")
      .withArgs(token, token, user1.address, tokenId, buyAmount);
    const user1Balance = await token.balanceOf(user1.address, tokenId);
    expect(user1Balance).to.equal(buyAmount);
  });

  it("Should reject buying fungible tokens if insufficient Ether is provided", async function () {
    const tokensToBuy = 10;
    const insufficientEther = currentTokenId * tokensToBuy - 1;
    await expect(
      token.connect(user1).purchaseTokens(user1.address, tokensToBuy, { value: insufficientEther })
    ).to.be.revertedWith("Insufficient funds to complete the purchase");
  });

  it("Should allow the minting of NFTs", async function () {
    const nftQuantity = 3;
    const requiredEther = currentTokenId * nftQuantity;
    await expect(
      token.connect(user1).purchaseNFT(user1.address, nftQuantity, { value: requiredEther })
    )
      .to.emit(token, "TransferSingle")
      .withArgs(user1.address, "0x0000000000000000000000000000000000000000", user1.address, NFTId, nftQuantity);
    const user1NFTBalance = await token.balanceOf(user1.address, NFTId);
    expect(user1NFTBalance).to.equal(nftQuantity);
  });

  it("Should reject minting of NFTs if it exceeds the maximum limit", async function () {
    await expect(
      token.connect(user1).purchaseNFT(user1.address, 10, { value: currentTokenId * 11 })
    ).to.be.revertedWith("Max limit exceeded");
  });

  it("Should allow safe token transfers between addresses", async function () {
    const tokensToTransfer = 5;
    const requiredEther = currentTokenId * tokensToTransfer;
    await token.connect(user1).purchaseTokens(user1.address, tokensToTransfer, { value: requiredEther });
    await token.connect(user1).safeTransferFrom(user1.address, user2.address, tokenId, tokensToTransfer, "0x");
    const user2Balance = await token.balanceOf(user2.address, tokenId);
    expect(user2Balance).to.equal(tokensToTransfer);
  });

  it("Should revert if attempting to transfer more tokens than are owned", async function () {
    const excessiveTransferAmount = 100;
    await expect(
      token.connect(user1).safeTransferFrom(user1.address, user2.address, tokenId, excessiveTransferAmount, "0x")
    ).to.be.reverted;
  });
});
