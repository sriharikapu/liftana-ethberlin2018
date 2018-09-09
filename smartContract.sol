pragma solidity ^0.4.21;


//rename before on a real system
contract MyContract {
    mapping (bytes32 => Claim) claimMap;
    bytes32[] claimKeyArray;
    mapping (bytes32 => bytes32[]) claimTags;
    bytes32[] claimTagArray;

    address public owner = msg.sender;
    
    mapping (address => uint) refundMap;

    uint public claimCost;
    uint public evidenceCost;

    enum EvidenceResolution {  Neutral, Positive, Negative }
    
    struct Claim {
        string title;
        uint date;
        Evidence[] evidenceList;
        bytes32[] tags;
    }

    struct Evidence {
        bytes32 evidenceHash;
        uint date;
        EvidenceResolution resolution;
    } 

    constructor( uint _claimCost, uint _evidenceCost )
        public
    {
        claimCost = _claimCost;
        evidenceCost = _evidenceCost;
    }

    function changeCosts (uint _claimCost, uint _evidenceCost) 
        public
    {
        require(owner == msg.sender);

        claimCost = _claimCost;
        evidenceCost = _evidenceCost;
    }

    event ClaimPost(
        bytes32 claimHash
    );
    
    event EventPost(
        bytes32 claimHash
    );

    //turn to mixin
    function postClaim(bytes32 bodyHash, string title, bytes32[] tags) 
        public
        payable
    {
        require(claimMap[bodyHash].date == 0);
        
        uint tagGasUse = 0;
        

        for(uint i = 0; i < tags.length; i++){
            if(claimTags[tags[i]].length == 0){
                tagGasUse += 66000;
            }else{
                tagGasUse += 26000;
            }
        }
        
        uint netClaimCost  = claimCost - tagGasUse*tx.gasprice;
        
        require(msg.value >= netClaimCost);
        
        uint refund = msg.value - netClaimCost;

        if(refund != 0){
            refundMap[msg.sender] = refund;
        }

        claimMap[bodyHash].title = title;
        claimMap[bodyHash].date = now;
        claimKeyArray.push(bodyHash);
        addTagsToClaims(bodyHash, tags);

        emit ClaimPost(bodyHash);     
    }

    function addTagsToClaims(bytes32 bodyHash, bytes32[] tags)
        private
    {
        claimMap[bodyHash].tags = tags;
        for(uint i; i < tags.length ;i++){
            //if this is the first time we've met this tag add it to tag array
            if(claimTags[tags[i]].length == 0){
                claimTagArray.push(tags[i]);
            }
            claimTags[tags[i]].push(bodyHash);
        }
    }

    //todo add fallback function ??? not sure if I should
    //using withdraw pattern
    //todod this might be too specific
    //todo difference between transfer and spend
    function withdraw()
        public
    {
        uint refundAmount = refundMap[msg.sender];
        refundMap[msg.sender] = 0;
        msg.sender.transfer(refundAmount);
    }

    function postEvidence(bytes32 claimHash, bytes32 evidenceHash, uint resolution)
        public 
        payable
        returns (bool)
    {
        require(msg.value > evidenceCost);

        uint refund = msg.value - evidenceCost;

        if(refund != 0){
            refundMap[msg.sender] = refund;
        }

        //need to do checks for paying to put content on the system
        Evidence memory newEvidence = Evidence(evidenceHash, now, EvidenceResolution(resolution));
        //add check that claimMap exists
        claimMap[claimHash].evidenceList.push(newEvidence);

        emit EventPost(evidenceHash);    
    }

    function getClaimLength()
        public
        constant //change to view
        returns (uint)
    {
        return claimKeyArray.length;
    }

    function getClaimHash(uint index)
        public
        constant
        returns (bytes32)
    {
        return claimKeyArray[index];
    }

    function getClaimInformation(bytes32 claimHash)
        public
        constant
        returns (string, uint, uint, bytes32[])
    {
        return (claimMap[claimHash].title, claimMap[claimHash].date, claimMap[claimHash].evidenceList.length, claimMap[claimHash].tags);
    }

    function getEvidenceFromClaim (bytes32 claimHash, uint evidenceIndex)
        public
        constant
        returns (bytes32, uint)
    {
        //todo how costly is this vanity variable? does the compiler automatically deal with it?
        Evidence memory thisEvidence = claimMap[claimHash].evidenceList[evidenceIndex];
        return (thisEvidence.evidenceHash, thisEvidence.date);
    }
    
    function getTagNameCount ()
        public
        constant
        returns (uint)
    {
        return claimTagArray.length;      
    }
    
    function getTagName (uint index)
        public
        constant
        returns (bytes32)
    {
        return claimTagArray[index];
    }
        
    function getTagUsageCount (bytes32 tagName)
        public
        constant
        returns (uint)
    {
        return claimTags[tagName].length;
    }
    
    function getClaimInTagUsage (bytes32 tagName ,uint index)
        public
        constant
        returns (bytes32)
    {
        return claimTags[tagName][index];
    }
}
