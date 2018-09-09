# Smart Contract

How to interact with smart contract:

Use `postClaim` and `postEvidence` to add claims and evidence to the system. Use `getClaimHash` and `getEvidenceFromClaim` to look at data in the system.


## API:

### Transactions

#### `changeCosts(uint _claimCost,  uint _evidenceCost)`

> Allows owner of contract to change price of submitting claims and evidence.

- `_claimCost`: number in 'wei' of how much a user has to pay to submit a claim
- `_evidenceCost`: number in 'wei' of how much a user has to pay to submit evidence


#### `postClaim(bytes32 bodyHash, string title, bytes32[] tags)`

> Allows user to post a claim

- `bodyHash`: hash of file on ipfs that has information about what the claim is. It is used as the id for a claim
- `title`: title of the claim
- `tags`: an array of tags, in bytes32 format such that claims can be added to them

Throws if hash already exists, Throws if not enough funds


#### `postEvidence(bytes32 claimHash, bytes32 evidenceHash, string title, uint256 sway)`

> Allows user to post evidence matching a claim

- `claimHash`: hash of the claim file on ipfs, as it's used for the id
- `evidenceHash`: hash of file on ipfs that has information about what evidence is
- `title`: title of the evidence
- `sway`: 0, 1, or 2, matching positive (supports claim) negative (is against claim) or neutral (simply increases general understanding) respectively

Throws if not enough funds

#### `withdraw(bytes32 claimHash, bytes32 evidenceHash, string title, uint256 sway)`

> Allows user to withdraw extra funds they may have added to account when posting evidence or posting claims


### Views

#### `claimCost`

> finds the value required to post a claim

returns
- `uint256`: cost in wei of posting a claim

#### `evidenceCost`

> finds the value required to post a piece of evidence

returns
- `uint256`: cost in wei of posting a piece of evidence


#### `getClaimLength()`

> gets number of claims submitted. Primarily good for going through all of the claims

returns
- 'uint256': number of claims submitted


#### `getClaimHash(uint256 index)`

> gets a claim hash corresponding to the index provided

- `index`: position in array of claimHashes to look

returns
- `bytes32`: cost in wei of posting a piece of evidence

#### `getClaimInformation(bytes32 claimHash)`

> gets important claim information for use

- `claimHash`: hash of claim document stored on ipfs, used as id of claim
returns

- `string`: title of claim
- `uint256`: date claim was submitted
- `uint256`: number of pieces of evidence submitted to claim

#### `getEvidenceFromClaim(bytes32 claimHash, uint256 evidenceIndex)`

> gets information for the given index of evidence from claim, probably used after getClaimInformation

- `claimHash`: hash of claim document stored on ipfs, used as id of claim
- `evidenceIndex`: index of evidence in claim

returns
- `bytes32`: ipfs hash for evidence
- `uint256`: date evidence was submitted

#### `getTagName(uint256 index)`

> gets tag name from index, used to find tag names if they are unknown

- `index`: index of tag name

returns
- `bytes32`: tag name as bytes32


#### `getTagNameCount()`

> gets number of unique tag names

returns
- `uint256`: number of tags

#### `getTagUsageCount(bytes32 tagName)`

> gets the number of claims with a given tag

- `tagName`: name of tag
returns
- `uint256`: number of tags

#### `getClaimInTagUsage(bytes32 tagName, uint index)`

> finds a claim with a given tag. To be used to find all the claims for a given tag, one at a time, using getTagUsageCount to find max index

- `tagName`: name of tag
- `index`: index to find claim
returns
- `bytes32`: ipfs hash of claim

#### `owner()`

> gets address of owner of contract

returns

- `address`: address of owner of contract
