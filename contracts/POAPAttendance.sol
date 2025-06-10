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
    uint256 public nextTokenId = 1;

    struct Attendance {
        string eventTitle;
        uint256 timestamp;
    }

    mapping(uint256 => Attendance) public attendanceMetadata;
    mapping(address => bool) public lecturers;

    event LecturerAdded(address indexed lecturer);
    event BadgeMinted(address indexed student, uint256 indexed tokenId);

    constructor() ERC721("AttendanceBadge", "BADGE") Ownable(msg.sender) {}

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
    function mintAttendanceBadge(
        address student,
        string memory tokenURI,
        string memory eventTitle
    ) public {
        require(lecturers[msg.sender], "Only lecturers can mint badges");

        uint256 tokenId = nextTokenId;
        _mint(student, tokenId);
        _setTokenURI(tokenId, tokenURI);

        attendanceMetadata[tokenId] = Attendance(eventTitle, block.timestamp);
        nextTokenId++;

        emit BadgeMinted(student, tokenId);
    }

    /// @notice Get badge details
    function getBadgeDetails(uint256 tokenId)
        public
        view
        returns (string memory eventTitle, uint256 timestamp, string memory uri)
    {
        require(ownerOf(tokenId) != address(0), "Badge does not exist");
        Attendance memory data = attendanceMetadata[tokenId];
        return (data.eventTitle, data.timestamp, tokenURI(tokenId));
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
}
