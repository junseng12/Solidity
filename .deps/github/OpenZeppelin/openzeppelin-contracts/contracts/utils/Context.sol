// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract EthSwap {
    ERC20 public token;
    uint256 public rate;

    constructor(ERC20 _token) {
        token = _token;
        rate = 100;
    }

    function getThisAddress() public view returns (address) {
        return address(this);
    }
    // 이 컨트랙트의 ca

    function getMsgSender() public view returns (address) {
        return msg.sender;
    }
    // 이 컨트랙트에 요청을 보낸 address

    function getToken() public view returns (address) {
        return address(token);
    }
    // token contract의 ca를 가져옴

    function getSwapBalance() public view returns (uint256) {
        return token.balanceOf(msg.sender);
    }
    // 요청을 보낸 사람이 요청한 토큰의 잔액을 보여주는 함수 

    function getTokenOwner() public view returns (address) {
        return token._owner();
    }
    // 토큰 최초발행자를 리텅

    function buyToken() public payable {
        uint256 tokenAmount = msg.value * rate;
        require(token.balanceOf(address(this)) >= tokenAmount, "error [1]");
        token.transfer(msg.sender, tokenAmount);
    }
    // 사용자가 보낸 이더리움 갯수의 일정 배율을 곱해 그 만큼의 토큰을 사용자에게 준다.
}