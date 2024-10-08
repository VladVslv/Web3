// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ERC721Token
 * @dev ERC721 токен с поддержкой URI для хранения метаданных и ограниченным количеством.
 *      Токен позволяет владельцу задавать базовый URI и управлять выпуском токенов.
 */
contract ERC721Token is ERC721, ERC721URIStorage, Ownable {
    uint256 public constant limit = 10;
    uint256 private supply = 0;
    uint256 private currentTokenId;
    string public dummyUri = "";

    /**
     * @dev Событие, вызываемое при создании нового токена.
     * @param id ID созданного токена
     */
    event CreatePenguin(uint256 indexed id);

    /**
     * @dev Конструктор, задающий начальную цену и владельца контракта.
     * @param owner Адрес владельца контракта
     * @param _price Цена одного токена в wei
     */
    constructor(
        address owner,
        uint256 _price
    ) ERC721("ERC721Token", "MTK721") Ownable(owner) {
        currentTokenId = _price;
    }

    /**
     * @dev Минт нескольких новых токенов.
     * @param recipient Адрес получателя токенов
     * @param count Количество токенов для минтинга
     *
     * Требования:
     * - Общее количество токенов не должно превышать макс. лимит.
     * - Достаточная сумма оплаты.
     */
    function mint(address recipient, uint256 count) public payable {
        uint256 total = _currentSupply();
        require(total + count < limit, "Max limit exceeded");
        require(msg.value >= currentTokenId * count, "Insufficient payment");

        for (uint256 i = 0; i < count; i++) {
            _mintSingleToken(recipient);
        }
    }

    /**
     * @dev Минт одного токена для указанного адресата.
     * @param recipient Адрес получателя токена
     */
    function _mintSingleToken(address recipient) private {
        uint id = _currentSupply();
        supply++;
        _safeMint(recipient, id);
    }

    /**
     * @dev Вычисление общей стоимости для заданного количества токенов.
     * @param count Количество токенов
     * @return Общая стоимость в wei
     */
    function getTotalPrice(uint256 count) public view returns (uint256) {
        return currentTokenId * count;
    }

    /**
     * @dev Возвращает текущее количество выпущенных токенов.
     * @return Общее количество выпущенных токенов
     */
    function _currentSupply() internal view returns (uint) {
        return supply;
    }

    /**
     * @dev Общее количество минтингованных токенов.
     * @return Количество минтингованных токенов
     */
    function totalSupply() public view returns (uint256) {
        return _currentSupply();
    }

    /**
     * @dev Возвращает базовый URI для метаданных.
     * @return Базовый URI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return dummyUri;
    }

    /**
     * @dev Устанавливает новый базовый URI. Только для владельца.
     * @param baseURI Новый базовый URI
     */
    function updateBaseURI(string memory baseURI) public onlyOwner {
        dummyUri = baseURI;
    }

    /**
     * @dev Возвращает URI для указанного токена.
     * @param tokenId ID токена
     * @return URI токена
     */
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        _requireOwned(tokenId);
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Проверяет поддержку интерфейса.
     * @param interfaceId Идентификатор интерфейса
     * @return True, если интерфейс поддерживается
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
