var Microcompany = artifacts.require("./Microcompany");
var MicrocompanyStorage = artifacts.require("./MicrocompanyStorage");
var VoteAddNewTask = artifacts.require("./VoteAddNewTask");
var AutoActionCaller = artifacts.require("./AutoActionCaller");

var CheckExceptions = require('./utils/checkexceptions');

global.contract('Microcompany', (accounts) => {
	let mcStorage;
	let mcInstance;

	const creator = accounts[0];
	const employee1 = accounts[1];
	const outsider = accounts[2];

	global.beforeEach(async() => {
		mcStorage = await MicrocompanyStorage.new({gas: 10000000, from: creator});
		const mcStorageAddress = mcStorage.address;

		mcInstance = await Microcompany.new(mcStorageAddress,{gas: 10000000, from: creator});
	});

	global.it('should set everything correctly',async() => {
		const isCan = await mcStorage.isCanDoByEmployee("addNewVote");
		global.assert.strictEqual(isCan,true,'Permission should be set correctly');

		const isMajority = await mcInstance.isInMajority(creator);
		global.assert.strictEqual(isMajority,true,'Creator should be in majority');

		const isMajority2 = await mcInstance.isInMajority(employee1);
		global.assert.strictEqual(isMajority2,false,'Employee should not be in majority');

		const isEmployeeByDefault = await mcInstance.isEmployee(creator);
		global.assert.strictEqual(isEmployeeByDefault,true,'Creator should be a first employee');
	});

	global.it('should return correct permissions for an outsider',async() => {
		const isCanDo1 = await mcInstance.isCanDoAction(outsider,"addNewVote");
		const isCanDo2 = await mcInstance.isCanDoAction(outsider,"startTask");
		const isCanDo3 = await mcInstance.isCanDoAction(outsider,"startBounty");
		global.assert.strictEqual(isCanDo1,false,'Outsider should not be able to do that ');
		global.assert.strictEqual(isCanDo2,false,'Outsider should not be able to do that ');
		global.assert.strictEqual(isCanDo3,false,'Outsider should not be able to do that ');

		const isCanDo4 = await mcInstance.isCanDoAction(outsider,"addNewEmployee");
		const isCanDo5 = await mcInstance.isCanDoAction(outsider,"addNewTask");
		const isCanDo6 = await mcInstance.isCanDoAction(outsider,"issueTokens");
		global.assert.strictEqual(isCanDo4,false,'Outsider should not be able to do that because he is in majority');
		global.assert.strictEqual(isCanDo5,false,'Outsider should not be able to do that because he is in majority');
		global.assert.strictEqual(isCanDo6,false,'Outsider should not be able to do that because he is in majority');
	});

	global.it('should return correct permissions for creator',async() => {
		const isCanDo1 = await mcInstance.isCanDoAction(creator,"addNewVote");
		const isCanDo2 = await mcInstance.isCanDoAction(creator,"startTask");
		const isCanDo3 = await mcInstance.isCanDoAction(creator,"startBounty");
		global.assert.strictEqual(isCanDo1,true,'Creator should be able to do that ');
		global.assert.strictEqual(isCanDo2,true,'Creator should be able to do that ');
		global.assert.strictEqual(isCanDo3,true,'Creator should be able to do that ');

		const isCanDo4 = await mcInstance.isCanDoAction(creator,"addNewEmployee");
		const isCanDo5 = await mcInstance.isCanDoAction(creator,"addNewTask");
		const isCanDo6 = await mcInstance.isCanDoAction(creator,"issueTokens");
		global.assert.strictEqual(isCanDo4,true,'Creator should be able to do that because he is in majority');
		global.assert.strictEqual(isCanDo5,true,'Creator should be able to do that because he is in majority');
		global.assert.strictEqual(isCanDo6,true,'Creator should be able to do that because he is in majority');
	});

	global.it('should not add new vote if not employee',async() => {
		// employee1 is still not added to Microcompany as an employee
		let newVote = 0x123;
		await CheckExceptions.checkContractThrows(mcInstance.addNewVote.sendTransaction,
			[newVote, { from: employee1}],
			'Should not add new vote because employee1 has no permission');
	});

	global.it('should add new vote by creator',async() => {
		let vote1 = await VoteAddNewTask.new(mcInstance.address,"SampleTaskCaption","SomeTaskDescription",false,false,100,
			{from: creator}
		);
		await mcInstance.addNewVote(vote1.address);
	});

	global.it('should require voting to add new employee by creator',async() => {
		// TODO:
	});

	global.it('should require voting to issue more tokens',async() => {
		// TODO:
		let aac = await AutoActionCaller.new(mcInstance.address, {from: creator});
		await aac.issueTokensAuto(employee1,1000,{from: creator});
	});

});

