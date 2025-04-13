// SPDX-License-Identifier: MIT
pragma solidity ~0.8.0;

contract CrowdFunding{

    string public campaignName;
    string public description;
    uint public targetAmount;
    uint public deadline;
    address public owner;
    enum CampaignState{Active, Successful, Failed}
    CampaignState public state;

    struct Tier{
        string name;
        uint256 amount;
        uint256 backers;
    }

    struct Backer{
        uint totalContribution;
        mapping (uint => bool) fundedTier;
    }

    mapping(address => Backer) public backers;

    Tier[] public tiers;

    modifier onlyOwner(){
        require (msg.sender == owner, "Only Owners Can Perform This Action");
        _;
    }
    modifier isCampaignActive(){
        require(state == CampaignState.Active, "Campaign is not Active");
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
        state = CampaignState.Active;
    }

    function checkAndUpdateCampaignState() internal{
        if(state == CampaignState.Active){
            if(block.timestamp >= deadline){
                    state = address(this).balance >= targetAmount? CampaignState.Successful :CampaignState.Failed;
            }else{
                   state = address(this).balance >= targetAmount? CampaignState.Successful :CampaignState.Active;
                }
            
        }
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

    function fund(uint256 _tierIndex)public payable isCampaignActive{
        require(block.timestamp < deadline, "Campaign has ended");
        require(_tierIndex < tiers.length, "Invalid Tier");
       require(msg.value == tiers[_tierIndex].amount , "Tier amount does not match"); 

       tiers[_tierIndex].backers++;
       backers[msg.sender].fundedTier[_tierIndex] = true;
       backers[msg.sender].totalContribution += msg.value;

    checkAndUpdateCampaignState();

    }
     function withdraw() public onlyOwner{
        checkAndUpdateCampaignState();
        require(state == CampaignState.Successful , "Campaign not yet Successful");

        uint256 balance = address(this).balance;

        require(balance > 0, "Transfer amount must be more than 0");

        payable(owner).transfer(balance); 

        
    }

     function getBalance()public view returns (uint256){
        return address(this).balance;
    }
    function refund() public {
        checkAndUpdateCampaignState();
        // require(state == CampaignState.Failed , "Refund is not available");


       uint amount =  backers[msg.sender].totalContribution;
       payable(msg.sender).transfer(amount);

    }
    
}