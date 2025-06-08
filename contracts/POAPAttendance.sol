// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title POAPAttendance
 * @dev A soulbound NFT system for issuing event attendance badges with role and expiry.
 */
contract POAPAttendance is ERC721URIStorage, Ownable {
    uint256 public nextTokenId = 1;

    struct Attendance {
        string eventTitle;
        string role;
        uint256 expiryTime; // 0 means never expires
    }

    mapping(uint256 => Attendance) public attendanceMetadata;
    mapping(address => bool) public validatedStudents;

    /// @notice Emitted when a student is validated
    event StudentValidated(address indexed student);

    /// @notice Emitted when a badge is minted
    event BadgeMinted(address indexed student, uint256 indexed tokenId);

    constructor(address initialOwner) ERC721("EventPOAP", "POAP") Ownable(initialOwner) {}

    /// @notice Validate a student's wallet before minting
    function validateStudent(address student) public onlyOwner {
        validatedStudents[student] = true;
        emit StudentValidated(student);
    }

    /// @notice Revoke a student's validation
    function revokeStudent(address student) public onlyOwner {
        validatedStudents[student] = false;
    }

    /// @notice Mint a soulbound POAP badge to a validated student
    function mintBadge(
        address student,
        string memory tokenURI,
        string memory eventTitle,
        string memory role,
        uint256 expiryTime
    ) public onlyOwner {
        require(validatedStudents[student], "Student not validated");

        uint256 tokenId = nextTokenId;
        _mint(student, tokenId);
        _setTokenURI(tokenId, tokenURI);

        attendanceMetadata[tokenId] = Attendance(eventTitle, role, expiryTime);
        nextTokenId++;

        emit BadgeMinted(student, tokenId);
    }

    /// @dev Enforce soulbound (non-transferable) by overriding _update (OpenZeppelin v5)
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        address from = _ownerOf(tokenId);
        require(from == address(0), "This NFT is soulbound and non-transferable");
        return super._update(to, tokenId, auth);
    }

    /// @notice Get role of a badge (e.g., Attendee, VIP)
    function getBadgeRole(uint256 tokenId) public view returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Badge does not exist");
        return attendanceMetadata[tokenId].role;
    }

    /// @notice Get event title of a badge
    function getEventTitle(uint256 tokenId) public view returns (string memory) {
        require(ownerOf(tokenId) != address(0), "Badge does not exist");
        return attendanceMetadata[tokenId].eventTitle;
    }

    /// @notice Check if the badge is still valid (based on expiry)
    function isBadgeValid(uint256 tokenId) public view returns (bool) {
        require(ownerOf(tokenId) != address(0), "Badge does not exist");
        uint256 expiry = attendanceMetadata[tokenId].expiryTime;
        if (expiry == 0) return true;
        return block.timestamp <= expiry;
    }

    /// @notice View all badge metadata
    function getBadgeMetadata(uint256 tokenId)
        public
        view
        returns (
            string memory eventTitle,
            string memory role,
            uint256 expiryTime,
            string memory uri
        )
    {
        require(ownerOf(tokenId) != address(0), "Badge does not exist");
        Attendance memory data = attendanceMetadata[tokenId];
        return (data.eventTitle, data.role, data.expiryTime, tokenURI(tokenId));
    }

    /// @notice Transfer ownership (admin handover)
    function transferOwnershipTo(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }
}
