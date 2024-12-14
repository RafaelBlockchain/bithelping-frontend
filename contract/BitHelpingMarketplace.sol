// SPDX-License-Identifier: MIT  
pragma solidity ^0.8.0;

// BHELP Token Interface (BEP20)
interface IBHELP {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingMarketplace {

    // BHELP token address
    IBHELP public bhelpToken;

    // Structure to store information about products (NFTs)
    struct Item {
        address payable seller;
        uint256 price;
        address nftContract;
        uint256 tokenId;
        bool isSold;
    }

    // Mapping of the items listed in the marketplace
    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    event ItemListed(uint256 itemId, address indexed seller, uint256 price, address indexed nftContract, uint256 tokenId);
    event ItemSold(uint256 itemId, address indexed buyer, uint256 price, address indexed nftContract, uint256 tokenId);

    constructor(address _bhelpToken) {
        bhelpToken = IBHELP(_bhelpToken);
    }

    // Modifier that checks that the price is greater than 0
    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price must be greater than zero.");
        _;
    }

    // List an NFT in the Marketplace
    function listItem(address _nftContract, uint256 _tokenId, uint256 _price) external priceGreaterThanZero(_price) {
        // Transfer the NFT to the contract so it can be transferred to the buyer after the sale
        IERC721(_nftContract).transferFrom(msg.sender, address(this), _tokenId);

        itemCount++;
        items[itemCount] = Item({
            seller: payable(msg.sender),
            price: _price,
            nftContract: _nftContract,
            tokenId: _tokenId,
            isSold: false
        });

        emit ItemListed(itemCount, msg.sender, _price, _nftContract, _tokenId);
    }

    // Buy a listed NFT
    function buyItem(uint256 _itemId) external {
        Item storage item = items[_itemId];
        
        require(!item.isSold, "Item already sold");
        require(bhelpToken.balanceOf(msg.sender) >= item.price, "Insufficient balance");

        // Transfer BHELP from the buyer to the seller
        bhelpToken.transferFrom(msg.sender, item.seller, item.price);

        // Mark the item as sold
        item.isSold = true;

        // Transfer the NFT to the buyer
        IERC721(item.nftContract).safeTransferFrom(address(this), msg.sender, item.tokenId);

        emit ItemSold(_itemId, msg.sender, item.price, item.nftContract, item.tokenId);
    }

    // Allow the seller to withdraw their balance
    function withdraw() external {
        uint256 balance = bhelpToken.balanceOf(msg.sender);
        require(balance > 0, "No funds available to withdraw");

        bhelpToken.transferFrom(address(this), msg.sender, balance);
    }
}

// Interface for ERC721 contracts (NFTs)
interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
}

