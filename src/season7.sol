// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0

pragma solidity ^0.8.20;

import "openzeppelin.sol";

contract EthTraderSpecialMembershipSeason7 is ERC721, ERC721Enumerable, ERC721URIStorage, AccessControl {
    uint256 private _nextTokenId;

    uint256 public DonutCostToMint;
    uint256 public TotalBurned;
    IERC20 private _donutToken;

    constructor() ERC721("EthTrader Special Membership (S07)", "ETSMS07") {        
        _donutToken = IERC20(0xF42e2B8bc2aF8B110b65be98dB1321B1ab8D44f5); 

        // initiliaze total burned
        TotalBurned = 0;

        // set the starting price to mint this
        DonutCostToMint = 1000;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, 0x0c4B8B79E0ebA3e407Bc175176Db496474046e9a);  // 0xMarcAurel
        _grantRole(DEFAULT_ADMIN_ROLE, 0x80148c5d2b61182107f43FAE67f8F2ec4b5dbcDE);  // Basoosh
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://raw.githubusercontent.com/EthTrader/memberships/main/meta/season_07.json";
    }

    function setMintPriceInDonut(uint256 newPrice) public onlyRole(DEFAULT_ADMIN_ROLE) {
        DonutCostToMint = newPrice;
    }

    function getMintPriceInDonut() public view returns (uint256) {
        return DonutCostToMint;
    }

    function isSeasonActive() public view returns (bool) {
        // season 7>= 2025/07/30 && < 2025/09/24
        return block.timestamp >= 1753855200 && block.timestamp < 1758693600;
    }

    function safeMint() public {
        safeMint(msg.sender);
    }

    function owners() external view returns (address[] memory) {
        uint256 totalSupply = totalSupply();
        address[] memory ownersList  = new address[](totalSupply);

        for (uint256 i=0; i < totalSupply; i++) {            
            ownersList [i] = ownerOf(tokenByIndex(i));
        }

        return ownersList ;
    }

    function safeMint(address to) public {
        require(isSeasonActive());
        require(_donutToken.balanceOf(msg.sender) >= DonutCostToMint * 1 ether);
        require(_donutToken.allowance(msg.sender, address(this)) >= DonutCostToMint * 1 ether);

        _donutToken.transferFrom(msg.sender, address(0xdead), DonutCostToMint * 1 ether);
        TotalBurned += DonutCostToMint;

        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function safeMintFree(address to) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(isSeasonActive());
        
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
