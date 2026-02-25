// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    // Owners of the wallet
    address[] public owners;
    uint public requiredSignatures;

    struct Transaction {
        address to;
        uint amount;
        bool executed;
        uint signatureCount;
    }

    // Mapping: txId => owner => signed
    mapping(uint => mapping(address => bool)) public signatures;

    Transaction[] public transactions;

    event Deposit(address indexed sender, uint amount);
    event TransactionCreated(uint indexed txId, address indexed to, uint amount);
    event TransactionExecuted(uint indexed txId);
    event TransactionSigned(uint indexed txId, address indexed owner);

    constructor(address[] memory _owners, uint _requiredSignatures) {
        require(_owners.length >= _requiredSignatures, "Owners less than required signatures");
        owners = _owners;
        requiredSignatures = _requiredSignatures;
    }

    modifier onlyOwner() {
        bool isOwner = false;
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Not an owner");
        _;
    }

    // Deposit ETH to the wallet
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    // Create a transaction
    function createTransaction(address _to, uint _amount) external onlyOwner {
        transactions.push(Transaction({
            to: _to,
            amount: _amount,
            executed: false,
            signatureCount: 0
        }));
        emit TransactionCreated(transactions.length - 1, _to, _amount);
    }

    // Sign a transaction
    function signTransaction(uint _txId) external onlyOwner {
        Transaction storage txn = transactions[_txId];
        require(!txn.executed, "Transaction already executed");
        require(!signatures[_txId][msg.sender], "Already signed");

        signatures[_txId][msg.sender] = true;
        txn.signatureCount++;

        emit TransactionSigned(_txId, msg.sender);
    }

    // Execute a transaction if enough signatures
    function executeTransaction(uint _txId) external onlyOwner {
        Transaction storage txn = transactions[_txId];
        require(!txn.executed, "Transaction already executed");
        require(txn.signatureCount >= requiredSignatures, "Not enough signatures");
        require(address(this).balance >= txn.amount, "Insufficient balance");

        txn.executed = true;
        payable(txn.to).transfer(txn.amount);

        emit TransactionExecuted(_txId);
    }

    // Get all transactions
    function getTransactions() external view returns (Transaction[] memory) {
        return transactions;
    }
}
