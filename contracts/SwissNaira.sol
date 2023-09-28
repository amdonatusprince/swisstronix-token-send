// SPDX-License-Identifier: MIT-License
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract sNGN is ERC20, Ownable {


    // The private mapping associates a boolean value with each Ethereum address to keep track of 
    // blacklisted addresses and prevent them from performing certain actions like transferring tokens.
    mapping(address => bool) private blacklist;

    // This mapping keeps track of Ethereum addresses allowed to mint G-Naira tokens, 
    // similar to the blacklist mapping.
    mapping(address => bool) private minter;

    // The purpose of this nested mapping is to track pending approval requests for certain actions by 
    // associating a uint256 value with each pair of Ethereum addresses until the request is approved or rejected.
    mapping(address => mapping(address => uint256)) private _pendingApprovals;

    // This variable is used in the contract to specify the minimum number of approvals required 
    // before a particular action can be executed. Specifically, 
    // this variable is used to enforce multi-signature approval for certain actions, 
    // such as minting or burning tokens.

    constructor() ERC20("Swiss-Naira", "sNGN") {}

    // This function mints new tokens and adds them to the balance of the recipient address. 
    // Only the contract owner (the "Governor") can call this function.

    function mint(address recipient, uint256 amount) public onlyGovernor {
        _mint(recipient, amount);
    }

    // This function burns (destroys) tokens from the balance of the owner address. 
    // Only the contract owner can call this function.

    function burn(address owner, uint256 amount) public onlyGovernor {
        _burn(owner, amount);
    }

    // This function adds an address to the contract's blacklist, 
    // which prevents them from sending or receiving tokens. 
    // Only the contract owner can call this function.

    function addToBlacklist(address account) public onlyGovernor {
        blacklist[account] = true;
    }

    // This function removes an address from the contract's blacklist. 
    // Only the contract owner can call this function.

    function removeFromBlacklist(address account) public onlyGovernor {
        blacklist[account] = false;
    }

    // This function adds an address to the contract's minter list, which allows them to mint new tokens. 
    // Only the contract owner can call this function.

    function addToMinter(address account) public onlyGovernor {
        minter[account] = true;
    }
    
    // This function removes an address from the contract's minter list. 
    // Only the contract owner can call this function.

    function removeFromMinter(address account) public onlyGovernor {
        minter[account] = false;
    }

    // This function transfers amount tokens from the sender's balance to the recipient address. 
    // Before transferring, it checks whether the sender or recipient is blacklisted. 
    // If either of them is blacklisted, the transfer fails.

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!blacklist[msg.sender], "Sender is blacklisted");
        require(!blacklist[recipient], "Recipient is blacklisted");
        return super.transfer(recipient, amount);
    }
    
    // This function transfers amount tokens from the sender address to the recipient address, 
    // but only if the sender has previously approved the transfer. 
    // Before transferring, it checks whether the sender or recipient is blacklisted. 
    // If either of them is blacklisted, the transfer fails.

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!blacklist[sender], "Sender is blacklisted");
        require(!blacklist[recipient], "Recipient is blacklisted");
        return super.transferFrom(sender, recipient, amount);
    }

    // This function allows a minter to request approval for minting new tokens to be sent to the recipient address. 
    // The minter specifies the amount of tokens to mint. 
    // The function adds the requested amount to the _pendingApprovals mapping for the msg.sender and recipient addresses. 
    // If the total amount requested is greater than or equal to half of the total supply of tokens, 
    // the function mints the tokens and resets the _pendingApprovals to 0.

    function mintWithApproval(address recipient, uint256 amount) public onlyMinter {
        _pendingApprovals[msg.sender][recipient] += amount;

        if (_pendingApprovals[msg.sender][recipient] >= totalSupply() / 2) {
            _mint(recipient, _pendingApprovals[msg.sender][recipient]);
            _pendingApprovals[msg.sender][recipient] = 0;
        }
    }

    // This function approves a pending mint request for the minter and 
    // recipient addresses by setting the _pendingApprovals mapping to 0. 
    // Only the contract owner can call this function.

    function approveMint(address minter, address recipient) public onlyGovernor {
        _pendingApprovals[minter][recipient] = 0;
    }

     // This function approves a burn request for the owner address by burning the specified amount of tokens. 
     // Only the contract owner can call this function.
    function approveBurn(address owner, uint256 amount) public onlyGovernor {
        _burn(owner, amount);
    }

    // This modifier is used to restrict access to functions that can only be called by the contract owner.

    modifier onlyGovernor() {
        require(owner() == msg.sender, "Caller is not the Governor");
        _;
    }

    // This modifier is used to restrict access to functions that can only be called by addresses
    //  that are on the contract's minter list.

    modifier onlyMinter() {
        require(minter[msg.sender], "Caller is not a Minter");
        _;
    }

    // This function is used to renounceOwnership and by defauult to 0x but when called does nothing
    
     function renounceOwnership() public pure override {}

}