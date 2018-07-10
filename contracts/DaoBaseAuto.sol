pragma solidity ^0.4.22;

import "./utils/GenericCaller.sol";

// TODO: convert to library?

/**
 * @title DaoBaseAuto
 * @dev This contract is a helper that will create new Proposal (i.e. voting) if the action is not allowed directly.
 * This should be used with DaoBaseWithUnpackers (not with DaoBase) and is completely optional.
 *
 * WARNING: As long as this contract is just an ordinary DaoBase client -> you should provide permissions to it
 * just like to any other account/contract. So you should give 'manageGroups', 'issueTokens', etc to the DaoBaseAuto!
 * Please see 'tests' folder for example.
*/
contract DaoBaseAuto is GenericCaller {

	bytes32 constant public MANAGE_GROUPS = keccak256("manageGroups");
	bytes32 constant public ISSUE_TOKENS = keccak256("issueTokens");
	bytes32 constant public UPGRADE_DAO_CONTRACT = keccak256("upgradeDaoContract");

	constructor(IDaoBase _dao)public
		GenericCaller(_dao)
	{
	}

	function addGroupMemberAuto(string _group, address _a) public returns(address proposalOut){
		bytes32[] memory params = new bytes32[](2);
		params[0] = bytes32(keccak256(_group));
		params[1] = bytes32(_a);

	   return doAction(MANAGE_GROUPS, dao, msg.sender,"addGroupMemberGeneric(bytes32[])",params);
	}

	function issueTokensAuto(address _token, address _to, uint _amount) public returns(address proposalOut){
		bytes32[] memory params = new bytes32[](3);
		params[0] = bytes32(_token);
		params[1] = bytes32(_to);
		params[2] = bytes32(_amount);

	   return doAction(ISSUE_TOKENS, dao, msg.sender,"issueTokensGeneric(bytes32[])",params);
	}

	function upgradeDaoContractAuto(address _newMc) public returns(address proposalOut){
		bytes32[] memory params = new bytes32[](1);
		params[0] = bytes32(_newMc);

		return doAction(UPGRADE_DAO_CONTRACT, dao, msg.sender,"upgradeDaoContractGeneric(bytes32[])",params);
	}

//  function removeGroupMemberAuto(string _groupName, address _a) public returns(address proposalOut) {
//    bytes32[] memory params = new bytes32[](2);
//    params[0] = bytes32(keccak256(_groupName));
//    params[1] = bytes32(_a);
//
//    return doAction(MANAGE_GROUPS, dao, msg.sender, "removeGroupMemberGeneric(bytes32[])", params);
//  }
//
//  function allowActionByShareholderAuto(string _what, address _tokenAddress) public returns(address proposalOut) {
//    bytes32[] memory params = new bytes32[](2);
//    params[0] = bytes32(keccak256(_what));
//    params[1] = bytes32(_tokenAddress);
//
//    return doAction(MANAGE_GROUPS, dao, msg.sender, "allowActionByShareholderGeneric(bytes32[])", params);
//  }
//
//  function allowActionByVotingAuto(string _what, address _tokenAddress) public returns(address proposalOut) {
//    bytes32[] memory params = new bytes32[](2);
//    params[0] = bytes32(keccak256(_what));
//    params[1] = bytes32(_tokenAddress);
//
//    return doAction(MANAGE_GROUPS, dao, msg.sender, "allowActionByVotingGeneric(bytes32[])", params);
//  }
//
//  function allowActionByAddressAuto(string _what, address _a) public returns(address proposalOut) {
//    bytes32[] memory params = new bytes32[](2);
//    params[0] = bytes32(keccak256(_what));
//    params[1] = bytes32(_a);
//
//    return doAction(MANAGE_GROUPS, dao, msg.sender, "allowActionByAddressGeneric(bytes32[])", params);
//  }
//
//  function allowActionByAnyMemberOfGroupAuto(string _what, string _groupName) public returns(address proposalOut) {
//    bytes32[] memory params = new bytes32[](2);
//    params[0] = bytes32(keccak256(_what));
//    params[1] = bytes32(keccak256(_groupName));
//
//    return doAction(MANAGE_GROUPS, dao, msg.sender, "allowActionByAnyMemberOfGroupGeneric(bytes32[])", params);
//  }

	// TODO: add other methods:
	/*
	function addGroup(string _groupName) public isCanDo("manageGroups")
   */
}

