// SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import ".deps/npm/@openzeppelin/contracts/token/ERC20/ERC20.sol";
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
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}


//PompayToken Deploy한 후, status 컨트랙트 Deploy하여 사용함
//ERC-20 토큰 컨트랙트 주소 : 0xfC713AAB72F97671bADcb14669248C4e922fe2Bb (PompayToken의 Deploy 주소)
contract status is PompayToken("AJOU", "AJ"){
    address private owner; // PompayToken 컨트랙트 배포자 주소 저장 - 초기에 생성자에서 할당하고 이후 변경 X (transfer함수를 통해, 항상 발행자로부터 토큰 얻을 수 있도록)
    ERC20 private token; // ERC-20 토큰 컨트랙트 주소 

     using SafeMath for uint256;

    constructor(address _tokenAddress) {
        owner = msg.sender; // 컨트랙트 배포자를 소유자로 설정 -- address(this) 이 컨트랙트 자체에 토큰 minting을 하면 transfer나 transferFrom에 오류
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
        require(amount <= balanceOf(msg.sender), "Insufficient rewards");

        //owner가 contract를 호출한 client인가? contract를 배포한 토큰 발행자인가?
        // owner = getTokenContractOwner();
        _transfer(msg.sender, to, amount);

        //지갑 소유자(to)의 balance 값 Update
        getInfoByWallet[to].balance = balanceOf(to);
        //balance 값 Update 후, ipfs 상에서도 새로 Update -- 임시로 닫음
        // uploadStudentInfoToIPFS(to);
        return true;
    }

    // function getBalanceOfWallet(address account) public view returns (uint256) {
    //     return getInfoByWallet[account].balance;
    // }

    //<--   IPFS 해시 저장 부분     -->//
    // IPFS 해시를 이더리움 블록체인에 저장하는 컨트랙트의 인스턴스 생성
    // IPFSStorage 컨트랙트 주소 : 0x16bBbD5bF6a7FDF52F896cC51162783e9e099179
    IPFSStorage ipfsStorage = IPFSStorage(0x0fC5025C764cE34df352757e82f7B5c4Df39A836);

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

}