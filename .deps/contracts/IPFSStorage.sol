// SPDX-License-Identifier:GPL-30
// 이더리움 메인 넷에 데이터의 IPFS 해시를 저장하는 컨트랙트
pragma solidity ^0.8.20;

 /**
   * @title IPFSStorage
   * @dev IPFSHash Saving
   * @custom:dev-run-script .deps/contracts/IPFSStorage.sol
   */


//디버그 - 발행자 account : 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
// 다른 Client 1 : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2  
contract IPFSStorage {
    // 여기에도 Student 구조체 정의하여 사용하니 ajoulinka 랑 구조체 충돌 발생
    // struct Student {
    //     string name;
    //     uint256 studentID;
    //     string major;
    //     uint256 gpa;
    //     string company;
    //     uint256 balance;
    // }
    mapping(address => string) public ipfsHashes; // 지갑 주소를 키로 사용하여 IPFS 해시를 저장
    
    // IPFS 해시를 생성하는 함수 - string화 부분
    function uintToString(uint256 value) public pure returns (string memory) {
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
    
    // 소수점이 있는 숫자를 문자열로 변환하는 함수
    function decimalToString(uint256 value, uint256 decimals) public pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint256 integerValue = value / (10**decimals);
        uint256 fractionalValue = value % (10**decimals);

        string memory integerValueString = uintToString(integerValue);
        string memory fractionalValueString = uintToString(fractionalValue);

        string memory result;

        if (fractionalValue > 0) {
            result = string(abi.encodePacked(integerValueString, ".", fractionalValueString));
        } else {
            result = integerValueString;
        }
        return result;
    }

    // IPFS 해시를 생성하는 함수 - Main
    // gpa 입력할 때 4.15는 415, 3.64는 364 형태로 입력해야 함
    function generateIPFSHash(
        string memory name,
        uint256 studentID,
        string memory major,
        uint256 gpa,
        string memory company,
        uint256 balance
    ) public pure returns (string memory) {
        string memory gpaString = decimalToString(gpa, 2); // 예시로 소수점 둘째 자리까지 표현

        return string(abi.encodePacked(
            name,
            uintToString(studentID),
            major,
            gpaString, // Convert gpa to string
            company,
            uintToString(balance)
        ));
    }
                
    // IPFS 해시를 저장하는 함수
    function saveIPFSHash(address account, string memory ipfsHash) public returns (bool) {
        // 다른 Client가 호출할 때마다, 다른 msg.sender로 잘 적용되나, transfer를 통해 다른 계정 balance Update 시 해당 계정에 적용하도록 하기 위해.
        // ipfsHashes[msg.sender] = ipfsHash;
        ipfsHashes[account] = ipfsHash;
        return true;
    }

    // IPFS 해시를 가져오는 함수
    function getIPFSHash(address account) public view returns (string memory) {
        require(bytes(ipfsHashes[account]).length > 0, "IPFS hash not found for the account. Please save IPFSHash about this account.");
        return ipfsHashes[account];
    }
}