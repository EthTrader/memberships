// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.20;

import "openzeppelin.sol";

contract EthTraderSpecialMembershipSeason2 is ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl {
    uint256 private _nextTokenId;

    bool public SeasonIsActive;
    uint256 public DonutCostToMint;
    uint256 public TotalBurned;
    IERC20 private _donutToken;

    constructor() ERC721("EthTrader Special Membership (S02)", "ETSMS02") {        
        _donutToken = IERC20(0xF42e2B8bc2aF8B110b65be98dB1321B1ab8D44f5); 

        // initiliaze total burned
        TotalBurned = 0;

        // set the starting price to mint this
        DonutCostToMint = 2;
        
        // set the season to active on contract creation
        SeasonIsActive = true;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://raw.githubusercontent.com/EthTrader/memberships/main/meta/season_02.json";
    }

    function setMintPriceInDonut(uint256 newPrice) public onlyRole(DEFAULT_ADMIN_ROLE) {
        DonutCostToMint = newPrice;
    }

    function getMintPriceInDonut() public view returns (uint256) {
        return DonutCostToMint;
    }

    function endSeason() public onlyRole(DEFAULT_ADMIN_ROLE) {
        SeasonIsActive = false;
    }

    function isSeasonActive() public view returns (bool) {
        return SeasonIsActive;
    }

    function safeMint() public {
        safeMint(msg.sender);
    }

    function safeMint(address to) public {
        require(SeasonIsActive);
        require(_donutToken.balanceOf(msg.sender) >= DonutCostToMint * 1 ether);
        require(_donutToken.allowance(msg.sender, address(this)) >= DonutCostToMint * 1 ether);

        _donutToken.transferFrom(msg.sender, address(0xdead), DonutCostToMint * 1 ether);
        TotalBurned += DonutCostToMint;

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function safeMintFree(address to) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(SeasonIsActive);
        
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        _requireOwned(tokenId);

        string memory baseURI = _baseURI();
        return baseURI;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}