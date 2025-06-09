const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("POAPAttendance", function () {
    let poapAttendance;
    let owner;
    let lecturer;
    let student;
    let student2;
    const eventTitle = "Web3 Development Workshop";
    const role = "Student";
    const tokenURI = "ipfs://Qm...";
    const expiryTime = Math.floor(Date.now() / 1000) + 86400; // 24 hours from now

    beforeEach(async function () {
        [owner, lecturer, student, student2] = await ethers.getSigners();
        
        const POAPAttendance = await ethers.getContractFactory("POAPAttendance");
        poapAttendance = await POAPAttendance.deploy(owner.address);
    });

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            expect(await poapAttendance.owner()).to.equal(owner.address);
        });

        it("Should initialize with correct name and symbol", async function () {
            expect(await poapAttendance.name()).to.equal("EventPOAP");
            expect(await poapAttendance.symbol()).to.equal("POAP");
        });
    });

    describe("Student Validation", function () {
        it("Should allow owner to validate a student", async function () {
            await expect(poapAttendance.validateStudent(student.address))
                .to.emit(poapAttendance, "StudentValidated")
                .withArgs(student.address);
            
            expect(await poapAttendance.validatedStudents(student.address)).to.be.true;
        });

        it("Should not allow non-owner to validate a student", async function () {
            await expect(poapAttendance.connect(lecturer).validateStudent(student.address))
                .to.be.revertedWithCustomError(poapAttendance, "OwnableUnauthorizedAccount");
        });

        it("Should allow owner to revoke student validation", async function () {
            await poapAttendance.validateStudent(student.address);
            await poapAttendance.revokeStudent(student.address);
            expect(await poapAttendance.validatedStudents(student.address)).to.be.false;
        });
    });

    describe("Badge Minting", function () {
        beforeEach(async function () {
            await poapAttendance.validateStudent(student.address);
        });

        it("Should mint a badge to a validated student", async function () {
            await expect(poapAttendance.mintBadge(
                student.address,
                tokenURI,
                eventTitle,
                role,
                expiryTime
            ))
                .to.emit(poapAttendance, "BadgeMinted")
                .withArgs(student.address, 1);

            expect(await poapAttendance.ownerOf(1)).to.equal(student.address);
            expect(await poapAttendance.getBadgeRole(1)).to.equal(role);
            expect(await poapAttendance.getEventTitle(1)).to.equal(eventTitle);
        });

        it("Should not mint a badge to an unvalidated student", async function () {
            await expect(poapAttendance.mintBadge(
                student2.address,
                tokenURI,
                eventTitle,
                role,
                expiryTime
            )).to.be.revertedWith("Student not validated");
        });

        it("Should not allow badge transfer", async function () {
            await poapAttendance.mintBadge(
                student.address,
                tokenURI,
                eventTitle,
                role,
                expiryTime
            );

            await expect(poapAttendance.connect(student).transferFrom(
                student.address,
                student2.address,
                1
            )).to.be.revertedWith("This NFT is soulbound and non-transferable");
        });
    });

    describe("Badge Metadata", function () {
        beforeEach(async function () {
            await poapAttendance.validateStudent(student.address);
            await poapAttendance.mintBadge(
                student.address,
                tokenURI,
                eventTitle,
                role,
                expiryTime
            );
        });

        it("Should return correct badge metadata", async function () {
            const [title, badgeRole, expiry, uri] = await poapAttendance.getBadgeMetadata(1);
            expect(title).to.equal(eventTitle);
            expect(badgeRole).to.equal(role);
            expect(expiry).to.equal(expiryTime);
            expect(uri).to.equal(tokenURI);
        });

        it("Should verify badge validity", async function () {
            expect(await poapAttendance.isBadgeValid(1)).to.be.true;
        });

        it("Should handle expired badges", async function () {
            // Mint a badge with immediate expiry
            await poapAttendance.mintBadge(
                student.address,
                tokenURI,
                eventTitle,
                role,
                1 // Expired timestamp
            );

            expect(await poapAttendance.isBadgeValid(2)).to.be.false;
        });
    });

    describe("Ownership Management", function () {
        it("Should allow owner to transfer ownership", async function () {
            await poapAttendance.transferOwnershipTo(lecturer.address);
            expect(await poapAttendance.owner()).to.equal(lecturer.address);
        });

        it("Should not allow non-owner to transfer ownership", async function () {
            await expect(poapAttendance.connect(lecturer).transferOwnershipTo(student.address))
                .to.be.revertedWithCustomError(poapAttendance, "OwnableUnauthorizedAccount");
        });
    });

    describe("Error Handling", function () {
        it("Should revert when querying non-existent badge", async function () {
            await expect(poapAttendance.getBadgeRole(999))
                .to.be.revertedWith("Badge does not exist");
        });

        it("Should revert when minting without validation", async function () {
            await expect(poapAttendance.mintBadge(
                student.address,
                tokenURI,
                eventTitle,
                role,
                expiryTime
            )).to.be.revertedWith("Student not validated");
        });
    });
}); 