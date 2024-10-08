// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/**
 * @title ERC20Token
 */
contract ERC20Token is ERC20Permit, Ownable {
    uint256 private currentTokenId; // Цена токена в wei
    uint256 public commissionPerc; // Процент комиссии за перевод

    /**
     * @dev Конструктор контракта
     * @param owner Адрес владельца контракта
     * @param _price Цена одного токена в wei
     * @param _commissionPerc Процент комиссии за перевод
     */
    constructor(address owner, uint256 _price, uint256 _commissionPerc)
        ERC20("MyToken", "MTK")
        Ownable(owner)
        ERC20Permit("MyToken")
    {
        _mint(msg.sender, 10 ** decimals());
        currentTokenId = _price;
        commissionPerc = _commissionPerc;
    }

    /**
     * @dev Позволяет пользователям покупать токены за эфир.
     *
     * Требования:
     *
     * - Отправленный эфир должен быть не менее цены одного токена.
     * - Контракт должен иметь достаточное количество токенов для продажи.
     */
    function buy() public payable {
        require(msg.value >= currentTokenId, "Not enough ETH sent");
        uint256 tokensToBuy = msg.value / currentTokenId;
        require(balanceOf(address(this)) >= tokensToBuy, "Not enough tokens");
        _transfer(address(this), msg.sender, tokensToBuy);
    }

    /**
     * @dev Перевод токенов с комиссией.
     * @param recipient Адрес получателя токенов
     * @param amount Количество токенов для перевода (до вычета комиссии)
     * @return True, если операция успешна
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * commissionPerc) / 100;
        _transfer(_msgSender(), address(this), fee);
        _transfer(_msgSender(), recipient, amount - fee);
        return true;
    }

    /**
     * @dev Перевод токенов от другого пользователя с комиссией.
     * @param sender Адрес отправителя токенов
     * @param recipient Адрес получателя токенов
     * @param amount Количество токенов для перевода (до вычета комиссии)
     * @return True, если операция успешна
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        uint256 fee = (amount * commissionPerc) / 100;
        uint256 allowanceAmount = allowance(sender, _msgSender());
        require(allowanceAmount >= amount, "Transfer exceeds allowance");
        _approve(sender, _msgSender(), allowanceAmount - amount);
        _transfer(sender, address(this), fee);
        _transfer(sender, recipient, amount - fee);
        return true;
    }

    /**
     * @dev Минт новых токенов указанному адресу. Только владелец может вызывать.
     * @param to Адрес, на который будут выпущены токены
     * @param amount Количество токенов для минтинга
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Пополнение контракта токенами. Только владелец может вызывать.
     * @param amount Количество токенов для пополнения
     */
    function fundContract(uint256 amount) external onlyOwner {
        _transfer(msg.sender, address(this), amount);
    }
}
