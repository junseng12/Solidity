# ✅ Solidity Smart Contract Work – AjouLinka Project

This repository contains smart contract development work completed as part of the **AjouLinka Project**, a career recommendation and link platform for undergraduate students at Ajou University, Korea.

🗓 **Duration:** July 2023 – August 2023  
👨‍💻 **Role:** Smart Contract Developer (Solidity)  
🎓 **Project Goal:** Customized career recommendation and link system

---

## 🔗 Project Repositories

- 🔹 **This Repository:** [junseng12/Solidity](https://github.com/junseng12/Solidity)  
  _Personal smart contract development space (Solidity only)_

- 🔹 **Full Project Repository:** [slayerzeroa/fe](https://github.com/slayerzeroa/fe)  
  _Contains the backend, frontend, and full system logic_

---

## 📁 Solidity Project Structure
```
contracts/
├── EtherSwap.sol          # Token swap smart contract
├── IPFSStorage.sol        # IPFS-based decentralized file storage
├── ajoulinka.sol          # Main AjouLinka smart contract logic
artifacts/                 # Auto-generated build outputs (JSON ABI etc.)
```
> This repo contains **only the Solidity contracts** developed and tested independently.  
> Final integration with the main project was handled via deployment and ABI sharing.

---

## 🎯 My Contribution & Learning Focus

- ✅ Developed an understanding of **Ethereum, tokens, and smart contracts**
- ✅ Built a **basic token swap system** using `EtherSwap.sol`
- ✅ Implemented **IPFS-based decentralized file storage** with `IPFSStorage.sol`
- ✅ Learned to structure reusable contracts and link them with external systems
- ✅ Connected Solidity code to the main platform backend via ABIs

---

## 🧠 Key Smart Contracts

| File               | Description                                     |
|--------------------|-------------------------------------------------|
| `EtherSwap.sol`     | Allows users to swap tokens (ERC-20 structure) |
| `IPFSStorage.sol`   | Stores IPFS hashes linked to user-submitted files |
| `ajoulinka.sol`     | Core logic for user connection & recommendation flow |

---

## 🛠 How to Use (for Solidity part)

1. Install dependencies (if using Hardhat):
   ```bash
   npm install
   ```

2. Compile contracts:
  ```bash
  npx hardhat compile
  ```
3. (Optional) Deploy to local/testnet using scripts

The full project includes backend services that communicate with these contracts using Web3.js or Ethers.js.

---

## 📚 Learning Context
This repository was created during the development of a collaborative university project.
My focus was on building decentralized contract logic and practicing Solidity through integration with:
- Ethereum testnets
- Token swap concepts
- IPFS (InterPlanetary File System)

##  License
This project is for educational and collaborative use only as part of Ajou University's student program.

