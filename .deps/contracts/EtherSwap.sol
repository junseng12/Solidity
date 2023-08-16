// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract EthSwap {
    ERC20 public token; // import 해온 ERC20.sol 파일에서 작성한 ERC20 컨트랙트의 public 부분을 모두 interface로 사용 
    uint public rate = 5000; // 1 Ether당 Token 비율 1:5000

    using SafeMath for uint256;
    
    // ERC20 토큰에 대한 CA 값이 인자값으로 들어갑니다.
    constructor(ERC20 _token) {
        token = _token;
    }

    function getToken()public view returns(address) {
        return address(token); // address(token) = swapToken의 CA 계정을 가져옴
    }
    
    function getThis() public view returns(address) {
        return address(this); // address(this) = ethSwap의 CA계정을 가져옴
    }

    function getMsgSender() public view returns(address) {
        return msg.sender; // 해당 컨트랙트를 실행시킨 EOA계정을 가져옴
    }

    //토큰 스왑량에 따라 Update 필요함
    function getBalanceOfContract() public view returns(uint256) {
        return token.balanceOf(address(this)); // swanToken의 owner ( 최최 배포자 ) EOA계정을 가져옴
    }

    // ETH -> Token 구매
    function buyToken() public payable {
        uint256 tokenAmount = (msg.value * rate).div(1e18); // 보내줄 토큰양 구하기

        require(token.balanceOf(address(this)) >= tokenAmount,"Not enough Tokens "); // EthSwap의 CA계정이 Token을 보내줄양이 충분한지 검증

        token.transfer(msg.sender,tokenAmount); // Contract 실행한 EOA계정에게 토큰 보내주기
    }

    // 이벤트 선언
    event Debug(uint256 amount, uint256 rate, uint256 etherAmount);

    // Token -> ETH 구매
    function sellToken(uint256 _amount) public payable {
        require(token.balanceOf(msg.sender) >= _amount); // Contract를 실행시킨 EOA계정의 스왑하려는 swapToken만큼의 양이 있는지 검증
        uint256 etherAmount = (_amount / rate); // 받은 SwapToken만큼 줘야할 ETH의 양
        require(address(this).balance >= etherAmount); //ethSwap CA계정이 가지고 있는 eth가 보내줘야하는 eth만큼 있는가 검증

        // 디버깅 로그 추가
        emit Debug(_amount, rate, etherAmount);

        // EthSwap 컨트랙트에 대한 사용자의 토큰 승인
        require(token.approve(address(this), _amount), "Approval failed");
        
        token.transferFrom(msg.sender, address(this), _amount); // Contract를 실행시킨 EOA 계정이 ethSwap CA계정에게 _amount 만큼 SwanToken을 보냅니다.
        payable(msg.sender).transfer(etherAmount.mul(1e18)); // ethSwap CA계정에서 Contract를 실행시킨 EOA 계정에게 etherAmount만큼의 ETH를 보내줍니다.
    }
}