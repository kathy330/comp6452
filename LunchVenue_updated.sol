/// SPDX - License - Identifier: UNLICENSED

pragma solidity ^0.8.0;

/// @title Contract to agree on the lunch venue
/// @author Dilum Bandara, CSIRO's Data61

contract LunchVenue {
    struct Friend {
        string name;
        bool voted; // Vote state
    }

    struct Vote {
        address voterAddress;
        uint restaurant;
    }
    enum VotingPhase {VoteCreate, VoteOpen, VoteClose} // weakness 3: vote process include well-defined create, vote open and vote close phase.

    mapping (uint => string) public restaurants; // list of restaurants (restaurant no, name)
    mapping (address => Friend) public friends; // list of friends (addresss, Friend)
    uint public numRestaurants = 0;
    uint public numFriends = 0;
    uint public numVotes = 0;
    address public manager; // Contract manager
    string public votedRestaurant = ""; // where to have lunch
    
    mapping (uint => Vote) public votes; // list of votes (vote no, Vote)
    mapping (uint => uint) private _results; // list of vote count (restaurant no, no of votes)
    // bool public voteOpen = true;
    // additional variables for weaknesses
    mapping (string => bool) public restaurantExists; //  weakness 2: check the restaurants have added or not
    VotingPhase public currentPhase = VotingPhase.VoteCreate; // weakness 3: determine the current phase
    uint public startBlock; // weakness 4: initial starting time block number
    uint public endBlock; // weakness 4: final ending time block number
    uint public currentTimeBlock; // weakness 4: to check the current time block number in the deploy pannel
    bool public isContractStartTimeout = false;
    bool public contractEnable = true; // weakness 5: flag the contract current status (enable/disable)
    
    /**
     * @dev Set manager when contract starts
     */
    constructor () {
        manager = msg.sender; // set contract creator as manager
        startBlock = block.number; // set the start time block number as the current block number
    }

    /**
     * @notice add a new restaurant
     * @dev to simplify the code, duplication of restaurants isn't checked
     *
     * @param name Restaurant name
     * @return Number of restaurant added so far
     */
    function addRestaurant ( string memory name ) public restricted isCreatePhase returns ( uint ){
        require(contractEnable, "Contract is disabled/cancelled"); // weakness 5: check contract enable or not
        require(bytes(name).length > 0, "Restaurant name cannot be empty"); // not all empty restaurant name
        require(!restaurantExists[name], "Cannot add the same restaurant twice"); // weakness 2: cannot add the same restaurant twice
        numRestaurants++;
        restaurants[numRestaurants] = name;
        restaurantExists[name] = true;
        return numRestaurants;
    }

    /**
     * @notice Add a new friend to voter list
     * @dev to simplifty the code duplication of friends is not checked
     *
     * @param friendAddress Friend's account/address
     * @param name Friend's name
     * @return Number of friends added so far
     */
    function addFriend(address friendAddress, string memory name) public restricted isCreatePhase returns (uint) {
        require(contractEnable, "Contract is disabled/cancelled"); // weakness 5: check contract enable or not
        require(bytes(friends[friendAddress].name).length == 0, "Friend address already exists"); // weakness 2: cannot add the same friends twice
        Friend memory f;
        f.name = name;
        f.voted = false;
        friends[friendAddress] = f;
        numFriends++;
        return numFriends;
    }

    
    /**
     * @notice Vote for a restaurant
     * @dev To simplify the code duplicate votes by a friend is not check
     *
     * @param restaurant Restaurant number being voted
     * @return validVote Is the vote valid? A valid vote should be from a registered friend to a registered restaurant
     */
    function doVote(uint restaurant) public isOpenPhase returns (bool validVote) {
        require(contractEnable, "Contract is disabled/cancelled"); // weakness 5: check contract enable or not
        require(!contractTimeout(), "Contract timeout"); // weakness 4: if contract timeout cannot vote.
        require(!friends[msg.sender].voted, "Cannot vote multiple time in one user"); // weakness 1: a friend cannot vote more than once
        validVote = false; // is the vote valid?
        if(bytes(friends[msg.sender].name).length != 0) { // does friend exist?
            if(bytes(restaurants[restaurant]).length != 0) { // does restaurant exist?
                validVote = true;
                friends[msg.sender].voted = true;
                Vote memory v;
                v.voterAddress = msg.sender;
                v.restaurant = restaurant;
                numVotes++;
                votes[numVotes] = v;
            }
        }

        if (numVotes >= numFriends/2 + 1 ) { // Quorum is met
            finalResult();
        }
        return validVote;
    }
    /**
     * @notice Determine winner resturant
     * @dev if top 2 restaurant have the same no of votes, result depends on vote order
     */
    function finalResult() private {
        uint highestVotes = 0;
        uint highestRestaurant = 0;

        for (uint i = 1; i <= numVotes; i++) { // For each vote
            uint voteCount = 1;
            if(_results[votes[i].restaurant] > 0) { // Already start counting
                voteCount += _results[votes[i].restaurant];
            }
            _results[votes[i].restaurant] = voteCount;

            if(voteCount > highestVotes) { // New winner
                highestVotes = voteCount;
                highestRestaurant = votes[i].restaurant;
            }
        }
        votedRestaurant = restaurants[highestRestaurant]; // Chosen restaurant
        currentPhase = VotingPhase.VoteClose; // change the voting phase to closed
        // voteOpen = false; // voting is now closed
    }

    /**
     * @notice Weakness 3: manager start voting phase
               Weakness 4: manager can set whent the contract is timeout by inputing the block number & 
                           contract start timeout in the vote open phase
     */
    function startVoting(uint timeoutBlockNumber) public restricted isCreatePhase{
        require(numFriends > 0, "Cannot start without friends"); // ensure there has more than 1 firends
        require(numRestaurants > 0, "Cannot start without restaurant"); // ensure there has more than 1 restaurant
        // match all the condition, start voting
        currentPhase = VotingPhase.VoteOpen;
        currentTimeBlock = block.number;
        endBlock = currentTimeBlock + timeoutBlockNumber;
        isContractStartTimeout = true;
    }

    /**
     * @notice Weakness 4 : check contract whether timeout or not
     */
    function contractTimeout() public returns (bool){
        currentTimeBlock = block.number;
        if(!isContractStartTimeout){
            return false;
        }
        if(currentTimeBlock > endBlock) {
            return true;
        } 
        return false;
    }
    
    /**
     * @notice Weakness 4 : show the deciede venue, if timeout or the voting phase is close.
     */
    function decideVenue() public returns (string memory){
        // if the voting has close, show result
        if (currentPhase == VotingPhase.VoteClose) {
            return votedRestaurant;
        } 
        // if the contract hasn't timeout return error msg
        currentTimeBlock = block.number;
        if (currentPhase == VotingPhase.VoteCreate) {
            revert("Contract in the vote create phase, decision not available.");
        } 
        if(currentTimeBlock < endBlock) {
            revert("Contract is not timeout yet, decision not available.");
        }
        // if timeout show result
        finalResult();
        return votedRestaurant;
    }

    /**
     * @notice Weakness 5: Determine whether the contact enable or not
     * @dev if the contact disable, it should disable the addFriends, addRestaurant, and doVote functions
     */
    function disableContract() public restricted returns (bool){
        require(contractEnable, "Contract is disabled/cancelled.");
        contractEnable = false;
        return true;
    }

    function enableContract() public restricted returns (bool){
        contractEnable = true;
        return true;
    }

    /**
     * @notice Weakness 3: Only can run during vote create phase
     */
    modifier isCreatePhase() {
        require(currentPhase == VotingPhase.VoteCreate, "Can only be run in create phase");
        _;
    }

    /**
     * @notice Weakness 3: Only can run during vote open phase
     */
    modifier isOpenPhase() {
        require(currentPhase == VotingPhase.VoteOpen, "Can vote only while voting is open");
        _;
    }

    /**
     * @notice Only the manager can do
     */
    modifier restricted() {
        require(msg.sender == manager, "Can only be executed by the manager");
        _;
    }
    /**
     * @notice  Only when voting is still open
     */
    // modifier votingOpen() {
    // require(voteOpen == true, "Can vote only while voting is open.");
    // _;
    // }
}