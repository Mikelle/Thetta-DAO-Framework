pragma solidity ^0.4.22;

import "../IDaoBase.sol";

import "../governance/Voting_1p1v.sol";
import "../governance/Proposals.sol";

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

/**
 * @title GenericCaller
 * @dev This is a wrapper that help us to do action that CAN require votings
 * WARNING: should be permitted to add new proposal by the current DaoBase!!!
*/
contract GenericCaller2 is DaoClient, Ownable {
	enum VotingType {
		NoVoting,

		Voting1p1v,
		VotingSimpleToken,
		VotingQuadratic
	}

	struct VotingParams {
		VotingType votingType;
		bytes32 param1;
		bytes32 param2;
		bytes32 param3;
		bytes32 param4;
		bytes32 param5;
	}

	mapping (bytes32=>VotingParams) votingParams;

	event GenericCaller_DoActionDirectly(string _permission, address _target, address _origin, string _methodSig);
	event GenericCaller_CreateNewProposal(string _permission, address _target, address _origin, string _methodSig);

/////
	constructor(IDaoBase _dao)public
		// DaoClient (for example) helps us to handle DaoBase upgrades
		// and will automatically update the 'dao' to the new instance
		DaoClient(_dao)	
	{
	}

	// EXPERIMENTAL approach 
	// See this: https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC827/ERC827Token.sol
	function doAction2(string _permissionId, address _target, address _origin, bytes _data) internal returns(address proposalOut) 
	{
		if(dao.isCanDoAction(msg.sender, _permissionId)){
			// we are in non-payable function here, so will not use msg.value!
			require(_target.call.value(0)(_data));
			return 0x0;
		}else{
			// 2 - create proposal + voting first  
			// _origin is the initial msg.sender (just like tx.origin) 
			GenericProposal2 prop = new GenericProposal2(_target, _origin, _data);

			IVoting voting = createVoting(_permissionId, prop, _origin);
			prop.setVoting(voting);

			// WARNING: should be permitted to add new proposal by the current contract address!!!
			// check your permissions or see examples (tests) how to do that correctly
			dao.addNewProposal(prop);		
			return prop;
		}
	}

	function setVotingParams(string _permissionId, uint _votingType, 
		bytes32 _param1, bytes32 _param2, 
		bytes32 _param3, bytes32 _param4, bytes32 _param5) public onlyOwner {
		VotingParams memory params;
		params.votingType = VotingType(_votingType);
		params.param1 = _param1;
		params.param2 = _param2;
		params.param3 = _param3;
		params.param4 = _param4;
		params.param5 = _param5;

		votingParams[keccak256(_permissionId)] = params;
	}

	function createVoting(string _permissionId, IProposal _proposal, address _origin)internal returns(IVoting){
		VotingParams memory vp = votingParams[keccak256(_permissionId)];

		if(VotingType.Voting1p1v==vp.votingType){
			return new Voting_1p1v(dao, _proposal, _origin, 
										  uint(vp.param1), 
										  bytes32ToString(vp.param2), 
										  uint(vp.param3), 
										  uint(vp.param4), 
										  vp.param5);
		}

		/*
		// TODO: 
		if(VotingType.VotingSimpleToken==vp.votingType){
			return new Voting_SimpleToken(dao, _proposal, _origin, uint(vp.param1), address(vp.param2), vp.param3);
		}
		*/

		// TODO: add other implementations
		// no implementation for this type!
		assert(false==true);
		return IVoting(0x0);
	}

	function bytes32ToString(bytes32 x)pure internal returns(string){
		bytes memory bytesString = new bytes(32);
		uint charCount = 0;
		for (uint j = 0; j < 32; j++) {
			byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
			if (char != 0) {
				bytesString[charCount] = char;
				charCount++;
			}
		}
		bytes memory bytesStringTrimmed = new bytes(charCount);
		for (j = 0; j < charCount; j++) {
			bytesStringTrimmed[j] = bytesString[j];
		}
		return string(bytesStringTrimmed);
	}	
}

