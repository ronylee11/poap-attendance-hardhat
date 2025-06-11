// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title POAPAttendance
 * @dev A simple NFT system for lecturers to issue attendance badges to students
 * with soulbound functionality (non-transferable)
 */
contract POAPAttendance is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    struct Attendance {
        string eventTitle;
        string role;
        uint256 expiryTime;
        uint256 mintedAt;
    }

    mapping(uint256 => Attendance) public attendanceMetadata;
    mapping(address => bool) public lecturers;
    mapping(address => uint256[]) public studentBadges;

    event LecturerAdded(address indexed lecturer);
    event BadgeMinted(address indexed student, uint256 indexed tokenId, string eventTitle);

    constructor() ERC721("AttendanceBadge", "BADGE") Ownable(msg.sender) {
        _nextTokenId = 1;
    }

    /// @notice Add a lecturer who can mint attendance badges
    function addLecturer(address lecturer) public onlyOwner {
        lecturers[lecturer] = true;
        emit LecturerAdded(lecturer);
    }

    /// @notice Remove a lecturer's minting rights
    function removeLecturer(address lecturer) public onlyOwner {
        lecturers[lecturer] = false;
    }

    /// @notice Mint an attendance badge to a student
    function mintBadge(
        address student,
        string memory tokenURI,
        string memory eventTitle,
        string memory role,
        uint256 expiryTime
    ) public {
        require(lecturers[msg.sender], "Only lecturers can mint badges");
        require(bytes(tokenURI).length > 0, "Token URI cannot be empty");
        require(bytes(eventTitle).length > 0, "Event title cannot be empty");

        uint256 tokenId = _nextTokenId;
        _nextTokenId++;

        // Mint the NFT
        _safeMint(student, tokenId);
        _setTokenURI(tokenId, tokenURI);

        // Store metadata
        attendanceMetadata[tokenId] = Attendance({
            eventTitle: eventTitle,
            role: role,
            expiryTime: expiryTime,
            mintedAt: block.timestamp
        });

        // Track student's badges
        studentBadges[student].push(tokenId);

        emit BadgeMinted(student, tokenId, eventTitle);
    }

    /// @notice Get badge details
    function getBadgeMetadata(uint256 tokenId)
        public
        view
        returns (
            string memory eventTitle,
            string memory role,
            uint256 expiryTime,
            uint256 mintedAt,
            string memory uri
        )
    {
        require(_exists(tokenId), "Badge does not exist");
        Attendance memory data = attendanceMetadata[tokenId];
        return (
            data.eventTitle,
            data.role,
            data.expiryTime,
            data.mintedAt,
            tokenURI(tokenId)
        );
    }

    /// @notice Check if a badge is still valid
    function isBadgeValid(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId), "Badge does not exist");
        Attendance memory data = attendanceMetadata[tokenId];
        return data.expiryTime == 0 || block.timestamp <= data.expiryTime;
    }

    /// @notice Get all badges owned by a student
    function getStudentBadges(address student) public view returns (uint256[] memory) {
        return studentBadges[student];
    }

    /// @notice Check if a student has a valid badge for an event
    function hasValidBadge(address student, string memory eventTitle) public view returns (bool) {
        uint256[] memory badges = studentBadges[student];
        for (uint256 i = 0; i < badges.length; i++) {
            Attendance memory data = attendanceMetadata[badges[i]];
            if (
                keccak256(bytes(data.eventTitle)) == keccak256(bytes(eventTitle)) &&
                (data.expiryTime == 0 || block.timestamp <= data.expiryTime)
            ) {
                return true;
            }
        }
        return false;
    }

    /// @dev Override _update to prevent transfers (soulbound functionality)
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);
        require(from == address(0), "Soulbound: This token cannot be transferred");
        return super._update(to, tokenId, auth);
    }

    /// @dev Override _exists to check if a token exists
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
