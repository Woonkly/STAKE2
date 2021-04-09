// SPDX-License-Identifier: GPL-3.0
    
pragma solidity ^0.6.6;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/REWARDManager.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testREWARDManager is REWARDManager {
    
    REWARDManager internal stm;
    address sc;
    
    constructor() public {
        
    }

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Here should instantiate tested contract
        newInOwners(address(this));
        stm=REWARDManager(address(this));

        sc=0x943c5bf93B09aAb282387D4d31f6289CdeB35653;
        

    }
    

    
    function testNewStake() public {

        uint256 li=newStake(TestsAccounts.getAccount(1),sc, 10**18);
        
        
        
        Assert.equal(li,1,"FAIL to create newStake");
        
        Assert.equal(getStakeCount(),1,"FAIL to create newStake");


        li=newStake(TestsAccounts.getAccount(2),sc, 10**18);
        
        Assert.equal(li,2,"FAIL to create newStake");
        
        Assert.equal(getStakeCount(),2,"FAIL to create newStake");

    }




    function testManageStake() public {
        
        address acc=TestsAccounts.getAccount(1);

        Assert.ok(manageStake(TestsAccounts.getAccount(3),sc, 10**18),"FAIL manageStake new");
        
        Assert.equal(getStakeCount(),3,"FAIL to create newStake new");
        
        Assert.ok(manageStake(acc,sc, 10**18),"FAIL manageStake add");

        (bool exist,bool scexist,uint256 rwd)=getStake(acc,  sc);

        Assert.equal(rwd,10**18*2,"FAIL to addToStake add");

    }
    

    function testChangeToken() public {
        
        Assert.ok(changeToken(TestsAccounts.getAccount(1),sc,10**15,1),"FAIL set changeToken 1");

        (bool exist,bool scexist,uint256 rwd)=getReward(TestsAccounts.getAccount(1),  sc);

        Assert.equal(rwd,10**15,"FAIL to changeToken  1 ");
        
        
        Assert.ok(changeToken(TestsAccounts.getAccount(1),sc,10**15,2),"FAIL set changeToken  2");
        
        ( exist, scexist, rwd)=getReward(TestsAccounts.getAccount(1),  sc);
        
        Assert.equal(rwd,10**15*2,"FAIL to changeToken 2 ");


        Assert.ok(changeToken(TestsAccounts.getAccount(1),sc,10**15,3),"FAIL set changeToken  3");
        
        ( exist, scexist, rwd)=getReward(TestsAccounts.getAccount(1),  sc);
        
        Assert.equal(rwd,10**15,"FAIL to changeToken  3 ");
    
    }


    function testRemoveStake() public {

        removeStake(TestsAccounts.getAccount(2));
        
        Assert.equal(getStakeCount(),2,"FAIL removeStake");
    }



    function testSubstractFromStake() public {
        

        stm.substractFromStake(TestsAccounts.getAccount(1),sc, 1);
        
        
        (bool exist,bool scexist,uint256 rwd)=getReward(TestsAccounts.getAccount(1),  sc);
        

        Assert.equal(rwd,(10**15)-1,"FAIL substractFromStake");

    }



    function testRenewStake()   public {
        
        stm.renewStake(TestsAccounts.getAccount(1),sc, 10**18);

        (bool exist,bool scexist,uint256 rwd)=getReward(TestsAccounts.getAccount(1),  sc);
        
        Assert.equal(rwd,10**18,"FAIL renewStake");
        
    }




    function testTransferStake() public{
        
        Assert.ok(stm.transferStake(TestsAccounts.getAccount(1), TestsAccounts.getAccount(3)),"FAIL transferStake");

        Assert.ok(!StakeExist(TestsAccounts.getAccount(1)),"FAIL transferStake acc 1 exist");
        
        Assert.ok(StakeExist(TestsAccounts.getAccount(3)),"FAIL transferStake acc 3 NOT exist");
        
    }
    


    function testRemoveAllStake() public{
        
        Assert.ok(stm.removeAllStake(),"FAIL removeAllStake");
        
        Assert.equal(getStakeCount(),0,"FAIL removeAllStake");
    }


}
