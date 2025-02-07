pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptiqueIncentives is Ownable {

    // Structure to represent a community
    struct Community {
        string name;
        address moderators; // Array of moderator addresses
        mapping(address => bool) isModerator; // Mapping to check if an address is a moderator
        mapping(string => SubCommunity) subCommunities; // Mapping of sub-community names to SubCommunity structs
    }

    // Structure to represent a sub-community
    struct SubCommunity {
        string name;
        bool isGated;
        GatingCriteria gatingCriteria; // Struct to store gating criteria (if applicable)
    }

    // Structure to represent gating criteria for a sub-community
    struct GatingCriteria {
        bool isTokenGated;
        address tokenAddress;
        uint256 tokenThreshold;
        bool isNFTGated;
        address nftAddress;
    }

    // Mapping of project addresses to a mapping of supported chains to token addresses
    mapping(address => mapping(string => address)) public projectWallets;

    // Mapping of project addresses to their community
    mapping(address => Community) public communities;

    // Events to log various actions
    event CommunityCreated(address project, string communityName);
    event SubCommunityCreated(address project, string communityName, string subCommunityName);
    event GatingCriteriaUpdated(address project, string communityName, string subCommunityName, GatingCriteria criteria);
    event TokensDeposited(address project, string chain, address token, uint256 amount);
    event TokensTransferred(address project, address user, string chain, address token, uint256 amount);
    event UserJoinedCommunity(address user, address project, string communityName);
    event UserJoinedSubCommunity(address user, address project, string communityName, string subCommunityName);

    // Modifier to check if a given address is a valid project wallet for a specific chain
    modifier onlyProjectWallet(address project, string memory chain) {
        require(projectWallets[project][chain]!= address(0), "Invalid project wallet for this chain");
        _;
    }

    // Function for projects to create a new community
    function createCommunity(string memory communityName) public {
        require(bytes(communities[msg.sender].name).length == 0, "Community already exists for this project");

        communities[msg.sender].name = communityName;
        communities[msg.sender].moderators.push(msg.sender); // Project owner is the initial moderator
        communities[msg.sender].isModerator[msg.sender] = true;

        emit CommunityCreated(msg.sender, communityName);
    }

    // Function to add a sub-community to a project's community
    function addSubCommunity(string memory communityName, string memory subCommunityName) public {
        require(bytes(communities[msg.sender].name).length > 0, "Community does not exist for this project");

        communities[msg.sender].subCommunities[subCommunityName] = SubCommunity(subCommunityName, false, GatingCriteria(false, address(0), 0, false, address(0)));

        emit SubCommunityCreated(msg.sender, communityName, subCommunityName);
    }

    // Function to set gating criteria for a sub-community
    function setGatingCriteria(string memory communityName, string memory subCommunityName, GatingCriteria memory criteria) public {
        require(bytes(communities[msg.sender].name).length > 0, "Community does not exist for this project");
        require(bytes(communities[msg.sender].subCommunities[subCommunityName].name).length > 0, "Sub-community does not exist");

        communities[msg.sender].subCommunities[subCommunityName].isGated = true;
        communities[msg.sender].subCommunities[subCommunityName].gatingCriteria = criteria;

        emit GatingCriteriaUpdated(msg.sender, communityName, subCommunityName, criteria);
    }

    // Function for projects to deposit tokens for incentives
    function depositTokens(string memory chain, address token, uint256 amount) public {
        require(token!= address(0), "Invalid token address");
        require(amount > 0, "Amount must be greater than 0");

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        projectWallets[msg.sender][chain] = token;

        emit TokensDeposited(msg.sender, chain, token, amount);
    }

    // Function for projects to transfer tokens to a user
    function transferTokens(address project, address user, string memory chain, uint256 amount) 
        public 
        onlyOwner 
        onlyProjectWallet(project, chain) 
    {
        require(user!= address(0), "Invalid user address");
        require(amount > 0, "Amount must be greater than 0");

        address token = projectWallets[project][chain];
        IERC20(token).transfer(user, amount);

        emit TokensTransferred(project, user, chain, token, amount);
    }

    // Function for users to join a community
    function joinCommunity(address project) public {
        require(bytes(communities[project].name).length > 0, "Community does not exist for this project");

        emit UserJoinedCommunity(msg.sender, project, communities[project].name);
    }

    // Function for users to join a sub-community
    function joinSubCommunity(address project, string memory communityName, string memory subCommunityName) public {
        require(bytes(communities[project].name).length > 0, "Community does not exist for this project");
        SubCommunity storage subCommunity = communities[project].subCommunities[subCommunityName];
        require(bytes(subCommunity.name).length > 0, "Sub-community does not exist");

        if (subCommunity.isGated) {
            require(meetsGatingCriteria(msg.sender, subCommunity.gatingCriteria), "User does not meet gating criteria");
        }

        emit UserJoinedSubCommunity(msg.sender, project, communityName, subCommunityName);
    }

    // Internal function to check if a user meets the gating criteria for a sub-community
    function meetsGatingCriteria(address user, GatingCriteria memory criteria) internal view returns (bool) {
        if (criteria.isTokenGated) {
            require(criteria.tokenAddress!= address(0), "Invalid token address");
            return IERC20(criteria.tokenAddress).balanceOf(user) >= criteria.tokenThreshold;
        } else if (criteria.isNFTGated) {
            require(criteria.nftAddress!= address(0), "Invalid NFT address");
            // Add logic here to check NFT ownership (e.g., using ERC721 balanceOf)
            //...
        }
        return true; // If no gating criteria are specified, return true
    }
}
