// SPDX-License-Identifier: GPL-3.0
        
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../LunchVenue_updated.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
// Inherit 'LunchVenue' contract
contract LunchVenueTest is LunchVenue {

    // Variable used to emulate different accounts
    address acc0;
    address acc1;
    address acc2;
    address acc3;
    address acc4;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Initiate account variables
        acc0 = TestsAccounts.getAccount(0);
        acc1 = TestsAccounts.getAccount(1);
        acc2 = TestsAccounts.getAccount(2);
        acc3 = TestsAccounts.getAccount(3);
        acc4 = TestsAccounts.getAccount(4);
    }

    /// Check manager
    /// account-0 is the default account that deploy contract, so it should be the manager
    function managerTest() public {
        Assert.equal(manager, acc0, "Manager should be acc0");
    }

    /// Add restaurant as manager
    /// When msg.sender isn't specified, default account (i,e., account-0) is the sender
    function setRestaurant() public {
        Assert.equal(addRestaurant('Countyard Cafe'), 1, 'Should be equal to 1');
        Assert.equal(addRestaurant('Uni Cafe'), 2, 'Should be equal to 2');
        Assert.equal(addRestaurant('City Cafe'), 3, 'Should be equal to 3');
    }

    /// Try to add a restaurant as a user other than manager. THis should fail
    /// #sender: account-1
    function setRestaurantFailure() public{
        // Try to catch reason for failure using try catch. When using
        // try-catch we need 'this' keyword to make function call external
        try this.addRestaurant('Atomic Cafe') returns (uint v){
            Assert.equal(v, 3, 'Method execution did not fail');
        } catch Error(string memory reason) {
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'Can only be executed by the manager','Failed with unexpected reason');
        } catch Panic(uint /* errorCode*/) { // In case of a panic
            Assert.ok(false, 'Failed unexpected with error code');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed. unexpected');
        }
    }

    // Set friend as account-0
    // #sender doesn't need to be specified explicitly for account-0
    function setFriends() public {
        Assert.equal(addFriend(acc0, 'Alice'), 1, 'Should be equal to 1');
        Assert.equal(addFriend(acc1, 'Bob'), 2, 'Should be equal to 2');
        Assert.equal(addFriend(acc2, 'Charlie'), 3, 'Should be equal to 3');
        Assert.equal(addFriend(acc3, 'Eve'), 4, 'Should be equal to 4');
    }

    /// Try adding friends as a user other than manager. This should fail
    function setFriendFailure() public {
        try this.addFriend(acc4, 'Daniels') returns (uint f) {
            Assert.notEqual(f, 5, 'Method execution did not fail');
        } catch Error(string memory reason) { // In case revert() called
            // Compare failure reason, check if it is as expected
            Assert.equal(reason, 'Can only be executed by the manager', 'Failed with unexpected reason');
        } catch Panic (uint /*errorCode*/) { // In case of a panic
            Assert.ok(false, 'Failed unexpected with error code');
        } catch (bytes memory /*lowLevelData*/){
            Assert.ok(false, 'Failed unexpected');
        }
    }

    /// weakness 2: same friends cannot be added multiple times
    function setFriendsMultipleFailure() public {
        try this.addFriend(acc3, 'Eve') returns (uint f) {
            Assert.equal(f, 5, 'Method execution did not fail');
        } catch Error(string memory reason) {
            string memory expectedReason = "Friend's address already exists";
            Assert.equal(reason, expectedReason, "Cannot added same friend twice");
        } catch Panic (uint /* errorCode */) {
            Assert.ok(false, "Failed unexpectedly with error code");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "Failed unexpectedly");
        }
    }

    /// weaknese 3: Verify voting before vote started. This should fail
    /// #sender: account-1
    function voteBeforeStartFailure() public {
        try this.doVote(1) returns (bool validVote) {
            Assert.equal(validVote, true, 'Method execution did not fail');
            // Assert.equal(validVote, "Can vote only while voting is open", "Voting should faled because not in the start phase");
        } catch Error(string memory reason) {
            // compare failure reason, check if it is as expected
            Assert.equal(reason, "Can vote only while voting is open", "Voting should faled because not in the start phase");
        } catch Panic (uint /* errorCode */) { // In case of a panic
            Assert.ok(false, 'Failed unexpected with error code');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpectedly');
        }
    }



    /// Vote as Alice (acc0)
    /// #sender: account-0 (manager)
    function votingStart() public {
        startVoting();
        // Assert.ok(doVote(1), "Voting result should be true");
    }

    /// Vote as Bob (acc1)
    /// #sender: account-1
    function vote() public {
        Assert.ok(doVote(1), "Voting result should be true");
    }

    /// weaknese 1: a friend cannot vote twice
    /// Vote as Bob (acc1)
    /// #sender: account-1
    function voteMoreThanOnceFailure() public {
        try this.doVote(1) returns (bool validVote) {
            Assert.ok(!validVote, "Voting should have failed");
        } catch Error(string memory reason) {
            string memory expectedReason = "Cannot vote multiple time in one user";
            Assert.equal(reason, expectedReason, "Unexpected failure reason");
        } catch Panic (uint /* errorCode */) {
            Assert.ok(false, "Failed unexpectedly with error code");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "Failed unexpectedly");
        }
    }


    /// Vote as Charlie (acc2)
    /// #sender: account-2
    function vote2() public {
        Assert.ok(doVote(2), "Voting result should be true");
    }

    /// Try voting as a user not in the friends list. This should fail
    /// #sender: account-7
    function voteFailure() public{
        Assert.equal(doVote(1), false, "Voting result should be false");
    }

    /// Vote as Eve
    /// #sender: account-3
    function vote3() public {
        Assert.ok(doVote(2), "Voting result should be true");
    }

    /// Verify lunch venue is set correctly
    function lunchVenueTest() public {
        Assert.equal(votedRestaurant, 'Uni Cafe', 'Selected restaurant should be Uni Cafe');
    }

    // /// Verify voting is now closed 
    // function voteOpenTest() public {
    //     Assert.equal(voteOpen, false, "Voting should be closed");
    // }

    /// Verify voting after vote closed. This should fail
    function voteAfterClosedFailure() public {
        try this.doVote(1) returns (bool validVote) {
            Assert.equal(validVote, true, 'Method execution did not fail');
        } catch Error(string memory reason) {
            // compare failure reason, check if it is as expected
            Assert.equal(reason, "Can vote only while voting is open", "Failed with unexpected reason");
        } catch Panic (uint /* errorCode */) { // In case of a panic
            Assert.ok(false, 'Failed unexpected with error code');
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, 'Failed unexpectedly');
        }
    }



}
    