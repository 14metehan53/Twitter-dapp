// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Tweether {

    //@@@@ EVENTS @@@@

    event CreateTweet(uint tweetId, address sender, string text, string image);
    event LikeTweet(uint tweetId, address sender);
    event DeleteTweet(uint tweetId, address sender);

    //@@@@ MODIFIERS @@@@

    // Tweet Control
    modifier exist(uint _tweetId) {
        require(_tweetId < lastTweetId, "the specified tweet doesn't exist");
        _;
    }

    // Check Tweet Owner
    modifier onlyOwner(uint _tweetId) {
        require(tweets[_tweetId].owner == msg.sender, "Not allowed");
        _;
    }
    
    struct Tweet {
        uint tweetId; // 0
        address owner; // this address => msg.sender
        uint[] replies; // []
        uint likes; // 0
        mapping (address => bool) likedBy; // address => false
        string text; // ""
        uint createdAt; // Block Timestamp => "4568975646"
        string image; // ""
        bool reply; // false
        uint repliedTo; // 0
    }

    uint public lastTweetId; // 0
    Tweet[] private tweets; // []

    constructor() {
        lastTweetId = 0;
    }


    // Create Tweet
    function CrtTweet(string memory _text, bool _reply, uint _repliedTo, string memory _image)  public returns(uint) {
        Tweet storage tweet = tweets.push();

        tweet.tweetId   = lastTweetId;
        tweet.owner     = msg.sender;
        tweet.text      = _text;
        tweet.createdAt = block.timestamp;
        tweet.reply     = _reply;
        tweet.repliedTo = _repliedTo;
        tweet.image     = _image;

        if (_reply == true && _repliedTo >= 0) {
            tweets[_repliedTo].replies.push(lastTweetId);
        }

        emit CreateTweet({tweetId: lastTweetId, sender: msg.sender, text: _text, image: _image});

        lastTweetId++; // +1
        return lastTweetId - 1;
    }

    // Tweet View
    function getTweet(uint _tweetId) public view exist(_tweetId) 
        returns(
            uint,
            address,
            uint[] memory,
            uint,
            bool,
            string memory,
            uint,
            bool,
            uint
        )
    {
        Tweet storage tweet = tweets[_tweetId];

        return (
            tweet.tweetId, // 0
            tweet.owner, // msg.sender 0x.000
            tweet.replies, // []
            tweet.likes, // 0
            tweet.likedBy[msg.sender], // address => false
            tweet.text, // ""
            tweet.createdAt, // Block Time => "1526789578"
            tweet.reply, // false
            tweet.repliedTo // 0
        );
    }


    // View Replies
    function getReplies(uint _tweetId) public view exist(_tweetId) 
    returns(
        uint[] memory
    )
    {
        // return array
        return tweets[_tweetId].replies;
    }


    // Like Tweet
    function likeTweet(uint _tweetId) public exist(_tweetId) 
        returns(
            bool
        ) 
    {
        if (tweets[_tweetId].likedBy[msg.sender] == true) {
            tweets[_tweetId].likes -= 1;
        } else {
            tweets[_tweetId].likes += 1;
        }

        /* 
           true = !false or false = !true
           If you like the tweet it will be true and if you like it again it will return false
        */
        tweets[_tweetId].likedBy[msg.sender] = !tweets[_tweetId].likedBy[msg.sender];

        emit LikeTweet({tweetId: _tweetId, sender: msg.sender});

        // return bool
        return tweets[_tweetId].likedBy[msg.sender];
    }


    // Delete Tweet
    function DelTweet(uint _tweetId) public exist(_tweetId) onlyOwner(_tweetId) 
        returns(
            bool
        )
    {
        // Deleting or changing data on the blockchain is very costly, so we are not completely deleting it. Therefore, we set each value of the tweet with this ID to zero.
        delete tweets[_tweetId];

        emit DeleteTweet({tweetId: lastTweetId, sender: msg.sender});

        return true;    
    }


    // Total Tweet View
    function getTotalTweet() public view 
    returns(
        uint
    ) 
    {
        // returns the length of all tweets
        return tweets.length;
    }

}