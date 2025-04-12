// SPDX-License Identifier: MIT
pragma solidity ~0.8.0;

contract CrowdFunding{

    string public campaignName;
    string public description;
    uint public targetAmount;
    uint public deadline;
    address public owner;

    struct Tier{
        string name;
        uint256 amount;
        uint256 backers;
    }

    Tier[] public tiers;

    modifier onlyOwner(){
        require (msg.sender == owner, "Only Owners Can Perform This Action");
        _;
    }

    constructor(string memory _campaignName, 
    string memory _description, 
    uint _targetAmount, uint256 _durationInDays){
        campaignName = _campaignName;
        description = _description;
        targetAmount = _targetAmount;
        deadline = block.timestamp + (_durationInDays * 1 days);
        owner = msg.sender;
    }

    function addTier (uint256 _amount, string memory _name)  public onlyOwner{
        require(_amount > 0, "Amount must be greater than zero");
         tiers.push(Tier(_name,_amount, 0 ));

    }

    function removeTier(uint256 _index) public onlyOwner{
        require(_index < tiers.length, "Tier does not exist");
         tiers[_index] = tiers[tiers.length - 1];
         tiers.pop();

    }

    function fund()public payable {
        require(msg.value > 0, "Must Fund Ammount Greater than Zero");
        require(block.timestamp < deadline, "Campaign has ended");

    }
     function withdraw() public onlyOwner{
        require(address(this).balance >= targetAmount , "Target amount has not been met");

        uint256 balance = address(this).balance;

        require(balance > 0, "Transfer amount must be more than 0");

        payable(owner).transfer(balance); 

        
    }

     function getBalance()public view returns (uint256){
        return address(this).balance;
    }
    
    // function getCampaignName() public view returns(string memory){
    //     return campaignName;
    // }

    // function getDescription() public view returns (string memory) {
    //     return description;
    // }

    // function getTargetAmount() public view returns  (uint256 amount_) {
    //     return targetAmount;
    // }

    // function getDeadline() public view returns(uint deadline_) {
    //     return deadline;
    // }

    // modifier deadlineChecker(){
    // }


}