var DaoBaseImpersonated = artifacts.require("./DaoBaseImpersonated");
var DaoBaseWithUnpackers = artifacts.require("./DaoBaseWithUnpackers");
var StdDaoToken = artifacts.require("./StdDaoToken");
var DaoStorage = artifacts.require("./DaoStorage");

var IVoting = artifacts.require("./IVoting");
var IProposal = artifacts.require("./IProposal");

function KECCAK256 (x) {
  return web3.sha3(x);
}

var utf8 = require('utf8');


contract('DaoBaseImpersonated', (accounts) => {
	let token;
	let store;
	let daoBase;
	let aacInstance;

	let issueTokens

	const creator = accounts[0];
	const employee1 = accounts[1];
	const employee2 = accounts[2];
	const outsider = accounts[3];

	beforeEach(async() => {
		token = await StdDaoToken.new("StdToken", "STDT", 18, true, true, true, 1000000000);
		await token.mint(creator, 1000);

		store = await DaoStorage.new([token.address], {from: creator});

		await store.addGroupMember(KECCAK256("Employees"), creator);
		await store.allowActionByAddress(KECCAK256("manageGroups"), creator);

		daoBase = await DaoBaseWithUnpackers.new(store.address, {from: creator});
		aacInstance = await DaoBaseWithUnpackers.new(daoBase.address, {from: creator});
	})
})