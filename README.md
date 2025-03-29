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

## 🔧 How to Deploy (Using Remix)

This Solidity project was developed and tested using the [Remix IDE](https://remix.ethereum.org/).  
Below are step-by-step instructions to deploy and interact with the contracts via Remix:

### 🖥️ Steps:

1. Go to 👉 [https://remix.ethereum.org/](https://remix.ethereum.org/)
2. Click **"Upload Folder"** (top-left) and select the `contracts/` folder from this project.
![image](https://github.com/user-attachments/assets/868c83fa-cbc6-4ffd-83b9-243c5331cd75)
3. Deploy the contracts in the following order:

markdown
```
1. IPFSStorage
2. PompayToken       (from within ajoulinka.sol)
3. status            (from within ajoulinka.sol)
4. EtherSwap
```

---

### ▶️ Deployment Instructions

1. **Deploy `IPFSStorage` first**  
   - Copy the deployed address.
   - Open `ajoulinka.sol` and go to line 88:  
     Replace:
     ```solidity
     IPFSStorage ipfsStorage = IPFSStorage(DeployedAddress);
     ```
     with your deployed address, e.g.:
     ![image](https://github.com/user-attachments/assets/67117aa8-8e38-492a-84a9-4fc6f38c49fc)

     ```solidity
     IPFSStorage ipfsStorage = IPFSStorage(0x16bBbD5bF6a7FDF52F896cC51162783e9e099179);
     ```

2. **Deploy `PompayToken`**  
   - Provide constructor arguments:  
     ```
     name: pompay
     symbol: PMP
     ```
     
   ![image](https://github.com/user-attachments/assets/a51fe646-db34-4e10-9489-22166e498332)

3. **Deploy `status` contract**

   ![image](https://github.com/user-attachments/assets/ce9d7139-21d8-4c53-a6db-c640a6d7cebd)
   - Provide the deployed address of `PompayToken` as a constructor argument, e.g.:
     ```
     0xd9145CCE52D386f254917e481eB44e9943F39138
     ```

5. **Deploy `EtherSwap`**
   
   ![image](https://github.com/user-attachments/assets/6f2ff4ea-95e6-4740-89d5-1f895791befc)
   - Provide the deployed address of `status` contract as constructor argument, e.g.:
     ```
     0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
     ```

> 💡 **Tip:**  
> For testing token swaps in `EtherSwap`, make sure to mint or fund both ETH and AJOU tokens beforehand.

---

## 📚 Learning Context

This repository was created during the development of a collaborative university project.  
My focus was on building decentralized contract logic and practicing Solidity through integration with:

- Ethereum testnets
- Token swap concepts
- IPFS (InterPlanetary File System)

---

## License

This project is for **educational and collaborative** use only as part of Ajou University's student program.

---

## 📚 Learning Context
This repository was created during the development of a collaborative university project.
My focus was on building decentralized contract logic and practicing Solidity through integration with:
- Ethereum testnets
- Token swap concepts
- IPFS (InterPlanetary File System)

##  License
This project is for educational and collaborative use only as part of Ajou University's student program.

