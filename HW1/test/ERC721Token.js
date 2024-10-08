const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721Token Contract", function () {
    let token;
    let owner, user1, user2;
    const currentTokenId = 1;

    beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();
        token = await (await ethers.getContractFactory("ERC721Token")).deploy(owner.address, currentTokenId);
    });

    it("Should successfully mint tokens and update the total count", async function () {
        await token.connect(user1).mint(user1.address, 2, { value: currentTokenId * 2 });
        expect(await token.totalSupply()).to.equal(2);
        await token.connect(user1).mint(user1.address, 3, { value: currentTokenId * 3 });
        expect(await token.totalSupply()).to.equal(5);
    });

    it("Should successfully mint tokens and update the total count", async function () {
        await token.connect(user1).mint(user1.address, 2, { value: currentTokenId * 2 });
        expect(await token.totalSupply()).to.equal(2);
        await token.connect(user1).mint(user1.address, 3, { value: currentTokenId * 3 });
        expect(await token.totalSupply()).to.equal(5);
    });

    it("Should prevent minting if maximum limit is surpassed", async function () {
        await expect(
            token.connect(user1).mint(user1.address, 11, { value: currentTokenId * 3 })
        ).to.be.revertedWith("Max limit exceeded");
    });

    it("Should prevent minting with insufficient payment", async function () {
        await expect(
            token.connect(user1).mint(user1.address, 2, { value: currentTokenId })
        ).to.be.revertedWith("Insufficient payment");
    });

    it("Should transfer token using transferFrom", async function () {
        await token.connect(user1).mint(user1.address, 3, { value: currentTokenId * 3 });
        await token.connect(user1).approve(user2.address, 1); // Approve tokenId 1 for user2
        await token.connect(user2).transferFrom(user1.address, user2.address, 1);
        expect(await token.ownerOf(1)).to.equal(user2.address);
    });

    it("Should prevent transferFrom if neither approved nor owner", async function () {
        await token.connect(user1).mint(user1.address, 3, { value: currentTokenId * 3 });
        await expect(
            token.connect(user2).transferFrom(user1.address, user2.address, 1)
        ).to.be.reverted;
    });

    it("Should execute a token transfer using safeTransferFrom", async function () {
        await token.connect(user1).mint(user1.address, 3, { value: currentTokenId * 3 });
        await token.connect(user1).approve(user2.address, 2);
        await token.connect(user2)["safeTransferFrom(address,address,uint256)"](user1.address, user2.address, 2);
        expect(await token.ownerOf(2)).to.equal(user2.address);
    });

    it("Should prevent safeTransferFrom if neither approved nor owner", async function () {
        await token.connect(user1).mint(user1.address, 3, { value: currentTokenId * 3 });
        await expect(
            token.connect(user2)["safeTransferFrom(address,address,uint256)"](user1.address, user2.address, 3)
        ).to.be.reverted;
    });
});
