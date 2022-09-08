// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";


contract GameSwap is Ownable {
    using SafeERC20 for IERC20;
    IERC20 geni_coin;
    mapping(address => uint256) public geni_gameCoin;
    event buy(address from,uint256 ammount);
    event sell(address from,uint256 ammount);

    constructor (IERC20 _tokenAddress) {
        geni_coin = _tokenAddress;
    }

    function SwapTOVCoin(uint256 _amount) external {
        require(geni_coin.balanceOf(msg.sender) >= _amount, "Low Amount!");
        geni_coin.transferFrom(msg.sender, address(this), _amount);
        geni_gameCoin[msg.sender] += _amount;
        emit buy(msg.sender,_amount);
    }

    function SwapTOCoin(uint256 _amount) external {
        require(geni_gameCoin[msg.sender] >= _amount, "You own less tokens than requested!");
        require(geni_coin.balanceOf(address(this)) >= _amount, "Contract does not have this ammount of balance!");
        geni_gameCoin[msg.sender] -= _amount;
        geni_coin.transfer(msg.sender, _amount);
        emit buy(msg.sender,_amount);
    }

    function getBalance(address _addr) external view returns (uint256){
        return geni_coin.balanceOf(_addr);
    }

    function isFunded(address _addr) external view returns(bool _isFunded) {
        if(geni_gameCoin[_addr] == 0)
            _isFunded = true;
        else 
            _isFunded = false;
        return _isFunded;
    }

    function resetAmount(address _addr) external onlyOwner {
        geni_gameCoin[_addr] = 0;
    }

    function setToken(IERC20 _address) external onlyOwner {
        geni_coin = _address;
    }

    function withdrawAmount() external onlyOwner {
        geni_coin.transfer(msg.sender, geni_coin.balanceOf(address(this)));
    }
}