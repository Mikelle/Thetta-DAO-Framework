pragma solidity ^0.4.22;

import "./IDaoBase.sol";

import "zeppelin-solidity/contracts/ECRecovery.sol";

// TODO: convert to library?

/**
 * @title ImpersonationCaller
 * @dev This is a convenient wrapper that is used by the contract below (see DaoBaseImpersonated). Do not use it directly.
*/
contract ImpersonationCaller is DaoClient {
	constructor(IDaoBase _dao) public DaoClient(_dao) {

	}

  /**
   * @dev Call action on behalf of the client
   * @param _hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param _sig bytes signature, the signature is generated using web3.eth.sign()
   */
	function doActionOnBehalfOf(bytes32 _hash, bytes _sig,
										 string _action, string _methodSig, bytes32[] _params) internal {

		// 1 - get the address of the client
		address client = ECRecovery.recover(_hash, _sig);

		// 2 - should be allowed to call action by a client
		require(dao.isCanDoAction(client, _action));

		// 3 - call
		if(!address(dao).call(
			bytes4(keccak256(_methodSig)),
			uint256(32),						 // pointer to the length of the array
			uint256(_params.length),		 // length of the array
			_params)){
			revert();
		}
	}
}

// TODO: convert to library?

/**
 * @title DaoBaseImpersonated
 * @dev This contract is a helper that will call the action is not allowed directly (by the current user) on behalf of the other user.
 * It is calling it really without any 'delegatecall' so msg.sender will be DaoBaseImpersonated, not the original user!
 *
 * WARNING: As long as this contract is just an ordinary DaoBase client -> you should provide permissions to it
 * just like to any other account/contract. So you should give 'manageGroups', 'issueTokens', etc to the DaoBaseImpersonated!
 * Please see 'tests' folder for example.
*/
contract DaoBaseImpersonated is ImpersonationCaller {

  event DaoBaseImpersonated_AllowActionByShareholder(string _what, address _tokenAddress);
  event DaoBaseImpersonated_AllowActionByVoting(string _what, address _tokenAddress);
  event DaoBaseImpersonated_AllowActionByAddress(string _group, address _a);
  event DaoBaseImpersonated_AllowActionByAnyMemberOfGroup(string _what, string _groupName);
  event DaoBaseImpersonated_AddGroup(string _group);
  event DaoBaseImpersonated_RemoveGroupMember(string _groupName, address _a);
  event DaoBaseImpersonated_AddGroupMember(string _groupName, address _a);
  constructor(IDaoBase _dao)public
		ImpersonationCaller(_dao)
	{
	}

  function upgradeDaoContractImp(bytes32 _hash, bytes _sig, address _newMc) public {
    bytes32[] memory params = new bytes32[](1);
    params[0] = bytes32(_newMc);

    return doActionOnBehalfOf(_hash, _sig, "upgradeDaoContract", "upgradeDaoContractGeneric(bytes32[])", params);
  }

	function issueTokensImp(bytes32 _hash, bytes _sig,
									 address _token, address _to, uint _amount) public {
		bytes32[] memory params = new bytes32[](3);
		params[0] = bytes32(_token);
		params[1] = bytes32(_to);
		params[2] = bytes32(_amount);

    return doActionOnBehalfOf(_hash, _sig, "issueTokens", "issueTokensGeneric(bytes32[])", params);
	}

  function allowActionByShareholderImp(bytes32 _hash, bytes _sig, string _what, address _tokenAddress) public {
    emit DaoBaseImpersonated_AllowActionByShareholder(_what, _tokenAddress);
    bytes32[] memory params = new bytes32[](2);
    params[0] = bytes32(_what);
    params[1] = bytes32(_tokenAddress);

    return doActionOnBehalfOf(_hash, _sig, "allowActionByShareholder", "allowActionByShareholderGeneric(bytes32[])", params);
  }

  function allowActionByVotingImp(bytes32 _hash, bytes _sig, string _what, address _tokenAddress) public {
    emit DaoBaseImpersonated_AllowActionByVoting(_what, _tokenAddress);
    bytes32[] memory params = new bytes32[](2);
    params[0] = bytes32(_what);
    params[1] = bytes32(_tokenAddress);

    return doActionOnBehalfOf(_hash, _sig, "allowActionByVoting", "allowActionByVotingGeneric(bytes32[])", params);
  }

  function allowActionByAddressImp(bytes32 _hash, bytes _sig, string _what, address _a) public {
    emit DaoBaseImpersonated_AllowActionByAddress(_what, _a);
    bytes32[] memory params = new bytes32[](2);
    params[0] = bytes32(_what);
    params[1] = bytes32(_a);

    return doActionOnBehalfOf(_hash, _sig, "allowActionByAddress", "allowActionByAddressGeneric(bytes32[])", params);
  }

  function allowActionByAnyMemberOfGroupImp(bytes32 _hash, bytes _sig, string _what, string _groupName) public {
    emit DaoBaseImpersonated_AllowActionByAnyMemberOfGroup(_what, _groupName);
    bytes32[] memory params = new bytes32[](2);
    params[0] = bytes32(_what);
    params[1] = bytes32(_groupName);

    return doActionOnBehalfOf(_hash, _sig, "allowActionByAnyMemberOfGroup", "allowActionByAnyMemberOfGroupGeneric(bytes32[])", params);
  }

  function removeGroupMemberImp(bytes32 _hash, bytes _sig, string _groupName, address _a) public {
    emit DaoBaseImpersonated_RemoveGroupMember(_groupName, _a);
    bytes32[] memory params = new bytes32[](2);
    params[0] = bytes32(_groupName);
    params[1] = bytes32(_a);

    return doActionOnBehalfOf(_hash, _sig, "removeGroupMember", "removeGroupMemberGeneric(bytes32[])", params);
  }

  function addGroupMemberImp(bytes32 _hash, bytes _sig, string _groupName, address _a) public {
    emit DaoBaseImpersonated_AddGroupMember(_groupName, _a);
    bytes32[] memory params = new bytes32[](2);
    params[0] = bytes32(_groupName);
    params[1] = bytes32(_a);

    return doActionOnBehalfOf(_hash, _sig, "addGroupMember", "addGroupMemberGeneric(bytes32[])", params);
  }

    // TODO: add other methods:
	/*
	function addGroup(string _groupName) public isCanDo("manageGroups")
   ...
   */
}


