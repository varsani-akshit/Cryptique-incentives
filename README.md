# Cryptique Incentives Smart Contract

This Solidity smart contract manages community creation, sub-community creation with gating criteria, token deposits, and token transfers for incentivizing users on the Cryptique platform.

## Features

* **Community Management:**
    * Allows projects to create communities.
    * Enables adding sub-communities to communities.
    * Supports setting gating criteria for sub-communities based on token holdings or NFT ownership.
* **Token Management:**
    * Allows projects to deposit tokens for incentives.
    * Enables transferring tokens to users based on their contributions.
* **Security:**
    * Uses modifiers to restrict access to certain functions.
    * Emits events to log important actions for transparency and auditability.
    * Leverages OpenZeppelin libraries for secure token handling and ownership management.

## Functions

* **`createCommunity(string memory communityName)`:**  Creates a new community for a project.
* **`addSubCommunity(string memory communityName, string memory subCommunityName)`:** Adds a sub-community to a project's community.
* **`setGatingCriteria(string memory communityName, string memory subCommunityName, GatingCriteria memory criteria)`:** Sets gating criteria for a sub-community.
* **`depositTokens(string memory chain, address token, uint256 amount)`:** Allows projects to deposit tokens for incentives.
* **`transferTokens(address project, address user, string memory chain, uint256 amount)`:** Transfers tokens from a project's deposited funds to a user.
* **`joinCommunity(address project)`:** Allows users to join a community.
* **`joinSubCommunity(address project, string memory communityName, string memory subCommunityName)`:** Allows users to join a sub-community (checks gating criteria if applicable).

## Structs

* **`Community`:** Represents a community with a name, moderators, and sub-communities.
* **`SubCommunity`:** Represents a sub-community with a name, gating status, and gating criteria.
* **`GatingCriteria`:** Stores the gating criteria for a sub-community (token or NFT based).

## Events

* **`CommunityCreated`:** Emitted when a new community is created.
* **`SubCommunityCreated`:** Emitted when a new sub-community is added.
* **`GatingCriteriaUpdated`:** Emitted when gating criteria for a sub-community are updated.
* **`TokensDeposited`:** Emitted when a project deposits tokens.
* **`TokensTransferred`:** Emitted when tokens are transferred to a user.
* **`UserJoinedCommunity`:** Emitted when a user joins a community.
* **`UserJoinedSubCommunity`:** Emitted when a user joins a sub-community.

## Usage

1. **Projects:**
   - Call `createCommunity` to create a community.
   - Call `addSubCommunity` to add sub-communities.
   - Call `setGatingCriteria` to set gating criteria for sub-communities (if required).
   - Call `depositTokens` to deposit tokens for incentivization.
2. **Cryptique Platform:**
   - Call `transferTokens` to transfer tokens to users based on their contributions.
3. **Users:**
   - Call `joinCommunity` to join a community.
   - Call `joinSubCommunity` to join a sub-community (gating criteria will be checked if applicable).

## Security Considerations

* **Audits:**  Have the contract audited by security professionals to identify and address potential vulnerabilities.
* **Access Control:**  Carefully manage access control to prevent unauthorized actions.
* **Gas Optimization:**  Optimize the contract code to minimize gas costs.
* **Upgradability:**  Consider implementing upgradeability mechanisms for future updates or bug fixes.

This smart contract provides a foundation for managing communities, sub-communities, and token incentives within the Cryptique platform.
