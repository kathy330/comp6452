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

    mapping (uint => string) public restaurants; // list of restaurants (restaurant no, name)
    mapping (address => Friend) public friends; // list of friends (addresss, Friend)
    uint public numRestaurants = 0;
    uint public numFriends = 0;
    uint public numVotes = 0;
    address public manager; // Contract manager
    string public votedRestaurant = ""; // where to have lunch
    
    mapping (uint => Vote) public votes; // list of votes (vote no, Vote)
    mapping (uint => uint) private _results; // list of vote count (restaurant no, no of votes)
    bool public voteOpen = true;
    
    /**
     * @dev Set manager when contract starts
     */
    constructor () {
        manager = msg.sender; // set contract creator as manager
    }

    /**
     * @notice add a new restaurant
     * @dev to simplify the code, duplication of restaurants isn't checked
     *
     * @param name Restaurant name
     * @return Number of restaurant added so far
     */
    function addRestaurant ( string memory name ) public restricted returns ( uint ){
        numRestaurants++;
        restaurants[numRestaurants] = name;
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
    function addFriend(address friendAddress, string memory name) public restricted returns (uint) {
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
    function doVote(uint restaurant) public votingOpen returns (bool validVote) {
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
        voteOpen = false; // voting is now closed
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
     modifier votingOpen() {
        require(voteOpen == true, "Can vote only while voting is open.");
        _;
     }
}