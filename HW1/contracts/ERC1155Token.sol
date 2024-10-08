// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

/**
 * @title ERC1155Token
 * @dev Контракт ERC1155, поддерживающий как NFT, так и FT, включает функции покупки и управления токенами.
 */
contract ERC1155Token is ERC1155, ERC1155URIStorage, ERC1155Holder, Ownable {
    uint256 private currentTokenId = 1;
    uint256 public constant tokenId = 0;
    uint256 private tokenCost = 1;
    uint256 public constant limit = 7;

    /**
     * @dev Конструктор, который инициализирует контракт в первичном состоянии.
     * @param initialOwner Адрес, который будет владельцем контракта.
     * @param _price Цена, устанавливаемая для покупки токена.
     */
    constructor(
        address initialOwner,
        uint256 _price
    )
        ERC1155("")
        Ownable(initialOwner)
    {
        _mint(address(this), tokenId, 1e18, "0x"); // Вначале выпускаем токены, чтобы создать запас
        tokenCost = _price;
    }

    /**
     * @dev Функция для покупки NFT токена.
     * @param recipient Адрес, на который будет отправлен токен.
     * @param quantity Количество токенов для покупки.
     *
     * Требования:
     * - Количество запрашиваемых токенов не должно превышать максимальный лимит.
     * - Достаточная сумма оплаты.
     */
    function purchaseNFT(address recipient, uint256 quantity) public payable {
        require(currentTokenId + quantity < limit, "Max limit exceeded");
        require(msg.value >= tokenCost * quantity, "Payment is below required value");

        uint id = currentTokenId;
        currentTokenId++;
        _mint(recipient, id, quantity, "");
    }

    /**
     * @dev Функция для покупки токенов.
     * @param recipient Адрес покупателя.
     * @param amount Количество токенов для покупки.
     */
    function purchaseTokens(address recipient, uint256 amount) public payable {
        uint256 totalCost = tokenCost * amount; // Общая стоимость токенов.
        require(
            msg.value >= totalCost,
            "Insufficient funds to complete the purchase"
        );
        require(
            balanceOf(address(this), tokenId) >= amount,
            "Insufficient tokens for sale"
        );

        // Произвести безопасный перевод токенов с контракта на адрес покупателя
        this.safeTransferFrom(address(this), recipient, tokenId, amount, "0x");
    }

    /**
     * @dev Возвращает URI для указанного идентификатора токена.
     * @param _tokenId Идентификатор токена.
     * @return Строка URI токена.
     */
    function uri(
        uint256 _tokenId
    ) public view override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return super.uri(_tokenId);
    }

    /**
     * @dev Массовый выпуск токенов на указанный адрес. Доступен только владельцу.
     * @param to Адрес, на который будут выпущены токены.
     * @param ids Массив идентификаторов токенов.
     * @param amounts Массив количеств для каждого токена.
     * @param data Дополнительные данные.
     */
    function issueTokenBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    /**
     * @dev Безопасный перевод одного типа токена.
     * @param from Адрес отправителя.
     * @param to Адрес получателя.
     * @param _tokenId Идентификатор токена.
     * @param amount Количество токенов для перевода.
     * @param data Дополнительные данные.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 _tokenId,
        uint256 amount,
        bytes memory data
    ) public override {
        super.safeTransferFrom(from, to, _tokenId, amount, data);
    }

    /**
     * @dev Безопасный перевод нескольких типов токенов одновременно.
     * @param from Адрес отправителя.
     * @param to Адрес получателя.
     * @param ids Массив идентификаторов токенов.
     * @param amounts Массив количеств токенов для каждого идентификатора.
     * @param data Дополнительные данные.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Проверяет поддержку интерфейсов.
     * @param interfaceId Идентификатор интерфейса.
     * @return Возвращает true, если интерфейс поддерживается.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, ERC1155Holder) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
