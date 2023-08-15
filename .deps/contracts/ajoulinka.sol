// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import  ".deps/contracts/IPFSStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

 /**
   * @title PompayToken
   * @dev ERC-20 Token Minting & Rewarding & Swapping
   * @custom:dev-run-script .deps/contracts/ajoulinka.sol
   */

//디버그 - 발행자 account : 0x583031D1113aD414F02576BD6afaBfb302140225
// - 수령인 account : 0xdD870fA1b7C4700F2BD7f44238821C26f7392148
// - 수령인2 account : 0xD25bD775E1B6077135B6837bA15f51a6D0E76Bd4
contract PompayToken is ERC20{
    uint public INITIAL_SUPPLY = 1500000000000000*10**18;
    constructor(string memory name, string memory symbol) ERC20(name,symbol){
        _mint(address(this), INITIAL_SUPPLY);
    }
}


//PompayToken Deploy한 후, status 컨트랙트 Deploy하여 사용함
//ERC-20 토큰 컨트랙트 주소 : 0xfC713AAB72F97671bADcb14669248C4e922fe2Bb (PompayToken의 Deploy 주소)
contract status is PompayToken("AJOU", "AJ"){
    address private owner; // PompayToken 컨트랙트 배포자 주소 저장 - 초기에 생성자에서 할당하고 이후 변경 X (transfer함수를 통해, 항상 발행자로부터 토큰 얻을 수 있도록)
    ERC20 private token; // ERC-20 토큰 컨트랙트 주소 

     using SafeMath for uint256;

    constructor(address _tokenAddress) {
        owner = address(this); // 컨트랙트 배포자를 소유자로 설정 -- address(this) 이 컨트랙트 자체에 토큰 minting을 하면 안되나?
        token = ERC20(_tokenAddress); // ERC-20 토큰 컨트랙트 주소 설정
    }
    
    function getTokenContractOwner() public view returns (address) {
        return owner;
    }

    //개인 식별 구조체
    struct Student {
        string name;
        uint256 studentID;
        string major;
        uint256 gpa;
        string company;
        uint256 balance;
    }
    
    // 보통 ERC20 토큰 컨트랙트에서는 토큰의 기호와 소수점 자리를 나타내는 자리수인 "decimals"도 함께 설정해야 함

    mapping(address => Student) public getInfoByWallet;
    
    // student 정보 설정 함수
    function setInfo(address account, string memory name, uint256 studentID, string memory major, uint256 gpa, string memory company) public {
        getInfoByWallet[account].name = name;
        getInfoByWallet[account].studentID = studentID;
        getInfoByWallet[account].major = major;
        getInfoByWallet[account].gpa = gpa;
        getInfoByWallet[account].company = company;
        getInfoByWallet[account].balance = balanceOf(account);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        // 보상 토큰 지급
        require(amount <= balanceOf(owner), "Insufficient rewards");

        //owner가 contract를 호출한 client인가? contract를 배포한 토큰 발행자인가?
        // owner = getTokenContractOwner();
        _transfer(owner, to, amount);

        //지갑 소유자(to)의 balance 값 Update
        getInfoByWallet[to].balance = balanceOf(to);
        //balance 값 Update 후, ipfs 상에서도 새로 Update
        uploadStudentInfoToIPFS(to);
        return true;
    }

    // function getBalanceOfWallet(address account) public view returns (uint256) {
    //     return getInfoByWallet[account].balance;
    // }

    //<--   IPFS 해시 저장 부분     -->//
    // IPFS 해시를 이더리움 블록체인에 저장하는 컨트랙트의 인스턴스 생성
    // IPFSStorage 컨트랙트 주소 : 0x16bBbD5bF6a7FDF52F896cC51162783e9e099179
    IPFSStorage ipfsStorage = IPFSStorage(0x16bBbD5bF6a7FDF52F896cC51162783e9e099179);

    // ipfsHash 값 어떻게 저장되는지 확인 못함
    //Student 정보를 해시하여 IPFS에 올리는 함수
    function uploadStudentInfoToIPFS(address account) public {
        Student memory student = getInfoByWallet[account];
        string memory ipfsHash = ipfsStorage.generateIPFSHash(student.name, student.studentID, student.major, student.gpa, student.company, student.balance);
        // string memory ipfsHash = ipfsStorage.generateIPFSHash(student);
        // IPFS 해시 저장 함수 호출
        ipfsStorage.saveIPFSHash(account, ipfsHash);
        // getInfoByWallet[msg.sender].ipfsHash = ipfsHash;
    }

    
 
    //IPFS 해시 값으로 Student 정보를 가져와 balance값을 보여주는 함수
    function getBalanceOfStudent(address account /*string memory /*ipfsHash*/) public view returns (uint256) {
        // // IPFSStorage 컨트랙트의 인스턴스를 생성
        // IPFSStorage ipfsStorage = IPFSStorage(0xd9145CCE52D386f254917e481eB44e9943F39138);
        Student memory student = getInfoByWallet[account];

        // IPFS 해시로부터 학생 ipfs 정보 획득 및 검증 
        string memory studentipfs = ipfsStorage.getIPFSHash(account);
        require(keccak256(abi.encodePacked(studentipfs)) == keccak256(abi.encodePacked(ipfsStorage.generateIPFSHash(student.name, 
        student.studentID, student.major, student.gpa, 
        student.company, student.balance))), "IPFS InCorrect");
        
        // balance 값 반환 - ipfs 는 그저 검증 용도 balance 반환에 큰 의미 X
        uint256 balance = getInfoByWallet[account].balance;
        return balance;
    }

    //<--  PompayToken을 Minting하는 부분     -->//
    function MintingTokens(address account, uint256 amount) public returns (bool) {
        // 원래는 주인만 minting 하도록 함 -> 실제 approve 과정을 거쳐야 minting 할 수 있게 되는데, 그냥 호출 제한 없앰
        // require(msg.sender == owner, "Only owner can mint tokens");
        _mint(account, amount);
        //balance 값 Update
        getInfoByWallet[account].balance = balanceOf(account);
        return true;
    }

    //<--  PompayToken을 다른 토큰과 스왑하는 부분     -->//
    event TokensSwapped(address indexed user, address indexed fromToken, uint256 fromAmount, address toToken, uint256 toAmount);
    
    // 확인
    // 스왑 과정에서 minting할 PompayToken의 양을 계산하는 함수
    function calculatePompayTokenAmount(address _otherTokenAddress, uint256 _otherTokenAmount, uint256 etherPrice, uint256 tokenPrice) public pure returns (uint256) {
        // 이더와 Pompay 토큰의 가치 비율 설정 (0.0002 이더 = 1 Pompay 토큰)
        uint256 etherToPompayRatio = 5000;  // 1 : 0.0002 = 5000 : 1

        // 다른 토큰의 가치를 이더로 환산하여 Pompay 토큰의 양 계산
        IERC20 otherToken = IERC20(_otherTokenAddress);
        // 실제로 다른 IERC 20 토큰과 이더 가치 비교 후 받아와야 함
        uint256 otherTokenValueInEther = calculateTokenValueInEther(otherToken, _otherTokenAmount, etherPrice, tokenPrice);
        // 이때, calculateTokenValueInEther 10의 18제곱한 정수 값을 실제 정수로 조정하여 토큰 발행량 맞춤(정수 값) - 일부 값 상실
        // 나중에 원한다면, 1e18 -> 1e10이나 이렇게 조정하여 실제 토큰 Swap 부분에서 세밀한 조정 가능
        uint256 pompayTokenAmount = (otherTokenValueInEther * etherToPompayRatio).div(1e18); 
        return pompayTokenAmount;
    }
    
    // 확인
    // 다른 토큰의 가치를 이더로 환산하여 반환하는 함수 (실제로는 실시간 가격 정보를 이용해야 함) - 나중에 쓰려고 IERC20 token 작성해놓음
    function calculateTokenValueInEther(IERC20 /*_token*/, uint256 tokenAmount, uint256 etherPrice, uint256 tokenPrice) public pure returns (uint256) {
        // ERC20 토큰 가격과 이더 가격의 비율 계산
        uint256 tokenToEtherRatio = tokenPrice.mul(1e18).div(etherPrice); // 1e18는 고정 소수점 18자리를 나타냅니다.
        
        // ERC20 토큰 가치를 이더 가치로 환산 - 10의 18제곱한 형태로 반환 (나중에 실수 값으로 표현하여 사용하기 위해서)
        uint256 tokenValueInEther = tokenAmount.mul(tokenToEtherRatio);

        return tokenValueInEther;
    }
 
    // 다른 Token을 AJOU Token으로 스왑하는 함수 (다른 토큰 지불 -> PompayToken 발행) 
    //디버그 예시: BNB Token Contract의 주소 : 0xB8c77482e45F1F44dE1745F52C74426C631bDD52
    function swapTokens(address otherTokenAddress, uint256 otherTokenAmount, uint256 etherPrice, uint256 tokenPrice) public {
        require(otherTokenAmount > 0, "Invalid amount");
        IERC20 otherToken = IERC20(otherTokenAddress);
        //다른 토큰을 스왑하는 과정에서 해당 토큰을 transferFrom 함수를 사용하여 스마트 컨트랙트로 전송하게 되면, 그 토큰은 스마트 컨트랙트의 소유가 됨
        //소유자의 지갑에서 해당 토큰이 빠져나온 것이 맞으며, 다른 기능을 수행하지 않으면 이 컨트랙트 내 예치됨 
        // 사용자의 토큰 소유자 계정에서 approve 함수를 호출하여 스마트 계약 주소에 대한 허용량 설정 필요
        require(otherToken.approve(address(this), otherTokenAmount), "Approval failed");
         //해당 토큰을 transferFrom 함수를 사용하여 스마트 컨트랙트로 전송
        require(otherToken.transferFrom(msg.sender, address(this), otherTokenAmount), "Token transfer failed");
    
        uint256 pompayTokenAmount = calculatePompayTokenAmount(otherTokenAddress, otherTokenAmount, etherPrice, tokenPrice); // 별도의 함수를 통해 계산
        require(pompayTokenAmount > 0, "Insufficient amount");

        //Swap을 호출한 해당 사용자 계정에 PompayToken 발행
        _mint(msg.sender, pompayTokenAmount); 
    
        emit TokensSwapped(msg.sender, otherTokenAddress, otherTokenAmount, address(this), pompayTokenAmount);
    }


    function calculateReceivedTokenAmount(uint256 ajouTokenAmount, uint256 etherPrice, uint256 tokenPrice) internal pure returns (uint256) {
        // ERC20 토큰 가격과 이더 가격의 비율 계산 - 사실 가격 자체 : 소수점 9자리로 처리해야 함.
        uint256 tokenToEtherRatio = tokenPrice / etherPrice;
        
        // Pompay 토큰 가치를 이더 가치로 환산 (0.0002 이더 = 1 Pompay 토큰)
        uint256 pompayTokenValueInEther = ajouTokenAmount * tokenToEtherRatio;

        // Pompay 토큰을 제시하고 받아야 할 다른 토큰의 양 계산 (0.0002 이더 = 1 Pompay 토큰)
        uint256 receivedTokenAmount = pompayTokenValueInEther * 5000;

        return receivedTokenAmount;
    }

    // AJOU Token을 다른 Token로 스왑하는 함수 (PompayToken -> 다른 토큰 발행) 
    // 이 컨트랙트 내에 toToken이 예치되어 있어야 함.(다른 Client가 해당 토큰에 대해 Swap하여 AJOU 토큰 발행하는 행동이 선행되어야 함)
    function swapAJOUTokens(address toTokenAddress, uint256 ajouTokenAmount, uint256 etherPrice, uint256 tokenPrice) public {
        require(ajouTokenAmount > 0, "Invalid amount");
        IERC20 ajouToken = IERC20(address(this)); // 이 컨트랙트가 AJOU tokens이 예치되어 있다는 것을 가정함.
        
        // Client -> 이 status Contract로 AJOU Token Transfer 진행
        require(ajouToken.transferFrom(msg.sender, address(this), ajouTokenAmount), "Token transfer failed");
        
        // Swap할 다른 ERC20 토큰 양 연산
        uint256 receivedTokenAmount = calculateReceivedTokenAmount(ajouTokenAmount, etherPrice, tokenPrice);
        require(receivedTokenAmount > 0, "Insufficient amount");
        
        // 호출자에게 receivedTokenAmount 만큼 다른 토큰 발행해줌 
        IERC20 toToken = IERC20(toTokenAddress);
        require(toToken.transfer(msg.sender, receivedTokenAmount), "Token transfer failed");
        
        emit TokensSwapped(msg.sender, address(ajouToken), ajouTokenAmount, toTokenAddress, receivedTokenAmount);
    }
}