// SPDX-License Identifier: MIT
pragma solidity  >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {

    IERC20 public s_stakingToken;   
    IERC20 public s_rewardToken;

    mapping(address => uint256) public s_balances;

    // a mapping of how much each address has been paid
    mapping(address => uint256) public s_userRewardPerTokenPaid;

    // how much rewards each address has
    mapping(address => uint) public s_rewards;

    uint256 public constant REWARD_RATE = 100;
    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;

    modifier updateReward(address account) {
        // how much is the reward per token?
        // last timestamp 
        s_rewardPerTokenStored = rewardPerToken(); 
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        require(amount != 0, "Fail, not mroe than zero"); 
        _;
    }

    // Based on how long its been during this most recent snapshot
    function rewardPerToken() public view returns(uint) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }

        return s_rewardPerTokenStored + ((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18 / s_totalSupply);
    }

    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken); 
        s_rewardToken = IERC20(rewardToken);
    }

    function earned(address account) public view returns(uint256) {
        uint currentBalance = s_balances[account];
        uint amountPaid = s_userRewardPerTokenPaid[account];
        uint currentRewardPerToken = rewardPerToken();
        uint pastRewards = s_rewards[account];

        uint _earned = ((currentBalance * (currentRewardPerToken - amountPaid))/1e18) + pastRewards;
        return _earned;
  } 

    function stake(uint256 amount) external updateReward(msg.sender) moreThanZero(amount){
        s_balances[msg.sender] += amount; 
        s_totalSupply += amount;

        //emit here
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Failed");
    }

    function withdraw(uint amount) external updateReward(msg.sender) moreThanZero(amount){
        s_balances[msg.sender] -= amount;
        s_totalSupply -= amount;
        bool success = s_stakingToken.transfer(msg.sender, amount);
    }

    function claimReward() external updateReward(msg.sender) {
        // contract will emit X tokens per second 
        // and disperse them to all token stakers
        // aka the more ppl that stake the less the reward

        uint reward = s_rewards[msg.sender];

        bool success = s_rewardToken.transfer(msg.sender, reward);

        require(success, "Fail");
    }
}