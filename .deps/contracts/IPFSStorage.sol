// SPDX-License-Identifier:GPL-30
// 이더리움 메인 넷에 데이터의 IPFS 해시를 저장하는 컨트랙트
pragma solidity ^0.8.0;

 /**
   * @title IPFSStorage
   * @dev IPFSHash Saving
   * @custom:dev-run-script .deps/contracts/IPFSStorage.sol
   */

//디버그 - 발행자 account : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// 다른 Client 1 : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2  
contract IPFSStorage {

    struct Student {
        string name;
        uint256 studentID;
        string major;
        uint256 gpa;
        string company;
        uint256 balance;
    }
    mapping(address => string) public ipfsHashes; // 지갑 주소를 키로 사용하여 IPFS 해시를 저장
    
    // IPFS 해시를 생성하는 함수 - string화 부분
    function toString(uint256 value) public pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    // IPFS 해시를 생성하는 함수 - Main
    function generateIPFSHash(Student memory student) public pure returns (string memory) {
        return string(abi.encodePacked(
            student.name,
            toString(student.studentID),
            student.major,
            toString(student.gpa),
            student.company,
            toString(student.balance)
        ));
    }

    // IPFS 해시를 저장하는 함수
    function saveIPFSHash(/*address account*/ string memory ipfsHash) public returns (bool) {
        // 다른 Client가 호출할 때마다, 다른 msg.sender로 잘 적용됨
        ipfsHashes[msg.sender] = ipfsHash;
        //ipfsHashes[account] = ipfsHash;
        return true;
    }

    // IPFS 해시를 가져오는 함수
    function getIPFSHash(address account) public view returns (string memory) {
        require(bytes(ipfsHashes[account]).length > 0, "IPFS hash not found for the account. Please save IPFSHash about this account.");
        return ipfsHashes[account];
    }
}