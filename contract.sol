// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
contract Wallet {
  
   address public owner;  // the address of the admin of the contract.
   mapping(address => User) public users;
 
   struct User {
       address userAddress;
       uint allowance; // his balance
       uint validity;
   }
 
  event AllowanceRenewed(address indexed user, uint allowance, uint timeLimit);
   event CoinsSpent(address indexed receiver, uint amount);
 
   modifier onlyOwner() {
       msg.sender == owner;
       _;
   }
 
   constructor() {
       owner = msg.sender;
   }
    //admin send some ETH to the contract to fund it. 
   receive() external payable onlyOwner {}
 
    //returns the current total balance of the wallet ((the contract))
   function getWalletBalance() public view returns (uint) {
       return address(this).balance;
   }
    //  update the allowance of a user.
   function renewAllowance(address _user, uint _allowance, uint _timeLimit) public onlyOwner {
       uint validity = block.timestamp + _timeLimit;
       users[_user] = User(_user, _allowance, validity);
       emit AllowanceRenewed(_user, _allowance, _timeLimit);
   }
    //return the pending allowance of a user
   function myAllowance() public view returns(uint) {
       return users[msg.sender].allowance;
   }
 
   function spendCoins(address payable _receiver, uint _amount) public {
       User storage user = users[msg.sender];
   require(block.timestamp < user.validity, "Validity expired!!");
   // checks if the amount to be spent is less than or equal to the allowance of the user
   require(_amount <= user.allowance, "Allowance not sufficient!!");
     
       user.allowance -= _amount;
       _receiver.transfer(_amount);
       emit CoinsSpent(_receiver, _amount);
   }
}