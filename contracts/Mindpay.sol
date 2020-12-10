// SPDX-License-Identifier: MIT;
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract Mindpay is ERC20,Ownable {
    
    /**
    calling the construtor during deployment of MIndPay contract.
     */

    uint256 public tokenPrice;


    // mapping container to track investment data


    struct User {
        uint256  invested;
        uint256 when;
    }

    //mapping 

    mapping(address => User)  public userInfo;


    // using safe math
    using SafeMath for uint256;

    constructor(string memory tokenName,string memory tokenSymbol, uint256 totalSupply)
    ERC20(tokenName,tokenSymbol)
    public {
        
        //mint the token  here
        _mint(msg.sender,totalSupply);

        // set the initial tokenPrice
        tokenPrice = 1000;
    }

    /**
    now the part of investment
     */

     function getRewardMultiplier(uint256 etherAmount) internal pure returns(uint256){
        
         if(etherAmount >1e18 || etherAmount < 5e18 ){
             return 10;
         }
         else if(etherAmount > 5e18){
             return 20;
         }
         else{
             return 0;
         }
     
     }

     // investment

     receive() payable external {
         
         uint256 etherValue = msg.value;
         address user = msg.sender;
         // here is investment logic
         uint256 investedAmount = etherValue.mul(90).div(100);
         // set this
         userInfo[user].invested  = userInfo[user].invested.add(investedAmount);
         userInfo[user].when = now;
         
     }

     function tokenToEtherConversion(uint256 etherValueInWei) public view returns(uint256) {
         return etherValueInWei.mul(tokenPrice);
     }

     

     // some owner functions to perform tasks
    function changeTokenPrice(uint256 _newTokenPrice) external onlyOwner {
        tokenPrice = _newTokenPrice;
    }

    // cancel Investment

   function unStake() external returns(bool) {
       address to = msg.sender;
       uint256 diff = now.sub(userInfo[to].when); 
       uint256 minutesResolve = uint256(15).mul(60).mul(1000);
       if(diff < minutesResolve) {
           revert("Investment Has been locked for 15 minuates");
       }
       else {
           // here is part of actual investment claim
           uint256 actualInvestment = userInfo[to].invested;

           // calculate bonus for his share
           uint256 rewardMultiplier = getRewardMultiplier(actualInvestment);
           uint256 bonusMinddeft = actualInvestment.mul(rewardMultiplier).div(100);

           // mint this to user account
           _mint(to,bonusMinddeft);
           
           // send ether
           msg.sender.transfer(actualInvestment);
           // revert to 0

           userInfo[to].invested = 0;
           userInfo[to].when  = 0;

           // burn from owner account
           _burn(owner(),bonusMinddeft);
           return true;

       }
   }

}