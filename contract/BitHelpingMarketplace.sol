// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interfaz del token BITH (ERC20)
interface IBITH {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BitHelpingMarketplace {

    // Dirección del token BITH
    IBITH public bithToken;

    // Estructura para almacenar la información de los productos (NFTs)
    struct Item {
        address payable seller;
        uint256 price;
        address nftContract;
        uint256 tokenId;
        bool isSold;
    }

    // Mapeo de los productos listados en el marketplace
    mapping(uint256 => Item) public items;
    uint256 public itemCount;

    event ItemListed(uint256 itemId, address indexed seller, uint256 price, address indexed nftContract, uint256 tokenId);
    event ItemSold(uint256 itemId, address indexed buyer, uint256 price, address indexed nftContract, uint256 tokenId);

    constructor(address _bithToken) {
        bithToken = IBITH(_bithToken);
    }

    // Modificador que verifica que el precio sea mayor a 0
    modifier priceGreaterThanZero(uint256 _price) {
        require(_price > 0, "Price must be greater than zero.");
        _;
    }

    // Listar un NFT en el Marketplace
    function listItem(address _nftContract, uint256 _tokenId, uint256 _price) external priceGreaterThanZero(_price) {
        // Transferir el NFT al contrato para que se pueda transferir al comprador después de la venta
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

    // Comprar un NFT listado
    function buyItem(uint256 _itemId) external {
        Item storage item = items[_itemId];
        
        require(!item.isSold, "Item already sold");
        require(bithToken.balanceOf(msg.sender) >= item.price, "Insufficient balance");

        // Transferir BITH desde el comprador al vendedor
        bithToken.transferFrom(msg.sender, item.seller, item.price);

        // Marcar el artículo como vendido
        item.isSold = true;

        // Transferir el NFT al comprador
        IERC721(item.nftContract).safeTransferFrom(address(this), msg.sender, item.tokenId);

        emit ItemSold(_itemId, msg.sender, item.price, item.nftContract, item.tokenId);
    }

    // Permitir que el vendedor retire su saldo
    function withdraw() external {
        uint256 balance = bithToken.balanceOf(msg.sender);
        require(balance > 0, "No funds available to withdraw");

        bithToken.transferFrom(address(this), msg.sender, balance);
    }
}

// Interfaz para contratos ERC721 (NFTs)
interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function ownerOf(uint256 tokenId) external view returns (address owner);
}
