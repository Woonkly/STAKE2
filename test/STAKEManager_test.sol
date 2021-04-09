// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.6;

import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/STAKEManager.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSTAKEmanager is STAKEManager {
    
    STAKEManager internal stm;
    
    constructor() 
        STAKEManager("TEST","TEST")
    public{
        
    }


    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Here should instantiate tested contract
        
        newInOwners(address(this));
        stm=STAKEManager(address(this));
        
    }


    


    function testNewStake() public {
        
        address acc=TestsAccounts.getAccount(1);
        
        uint256 li=newStake(acc, 10**18,10**16,10**15,true);
        
        Assert.equal(li,1,"FAIL to create newStake");
        
        Assert.equal(getStakeCount(),1,"FAIL to create newStake");


    }




    function testAddStake() public {
        
        address acc=TestsAccounts.getAccount(1);

        addToStake(acc,10**18 );

        address accr;uint256 bal;uint256 bnb;uint256 woop;bool autoc;
        
        ( accr, bal, bnb,woop,autoc)=  getStake(acc);

        Assert.equal(bal,10**18*2,"FAIL to create addToStake");
    }


    function testManageStake() public {
        
        address acc=TestsAccounts.getAccount(1);

        Assert.ok(manageStake(TestsAccounts.getAccount(2), 10**18),"FAIL manageStake new");
        
        Assert.equal(getStakeCount(),2,"FAIL to create newStake new");
        
        Assert.ok(manageStake(acc, 10**18),"FAIL manageStake add");

        address accr;uint256 bal;uint256 bnb;uint256 woop;bool autoc;
        ( accr, bal, bnb,woop,autoc)=  getStake(acc);
        
        Assert.equal(bal,10**18*3,"FAIL to addToStake add");

    }


    function testSetAutocompoundStake() public {
        
        address acc=TestsAccounts.getAccount(1);

        setAutoCompound(acc, false);
        
        bool autoc=getAutoCompoundStatus(acc);

        Assert.ok(!autoc,"FAIL set autocompound");
        
    }
    
    
    function testChangeTokenBNB() public {
        
        Assert.ok(changeToken(TestsAccounts.getAccount(1),10**15,1,true),"FAIL set changeToken bnb 1");
        
        bool exist;uint256 bnb;uint256 woop;bool autoc;
        ( exist, bnb,woop,autoc)=  getValues(TestsAccounts.getAccount(1));
        
        Assert.equal(bnb,10**15,"FAIL to changeToken bnb 1 ");
        
        
        Assert.ok(changeToken(TestsAccounts.getAccount(1),10**15,2,true),"FAIL set changeToken bnb 2");
        
        ( exist, bnb,woop,autoc)=  getValues(TestsAccounts.getAccount(1));
        
        Assert.equal(bnb,10**15*2,"FAIL to changeToken bnb 2 ");


        Assert.ok(changeToken(TestsAccounts.getAccount(1),10**15,3,true),"FAIL set changeToken bnb 3");
        
        ( exist, bnb,woop,autoc)=  getValues(TestsAccounts.getAccount(1));
        
        Assert.equal(bnb,10**15,"FAIL to changeToken bnb 3 ");
    
    }


    function testChangeTokenWOOP() public {
        
        Assert.ok(changeToken(TestsAccounts.getAccount(1),10**14,1,false),"FAIL set changeToken WOOP 1");
        
        bool exist;uint256 bnb;uint256 woop;bool autoc;
        ( exist, bnb,woop,autoc)=  getValues(TestsAccounts.getAccount(1));
        
        Assert.equal(woop,10**14,"FAIL to changeToken WOOP 1 ");
        
        
        Assert.ok(changeToken(TestsAccounts.getAccount(1),10**14,2,false),"FAIL set changeToken WOOP 2");
        
        ( exist, bnb,woop,autoc)=  getValues(TestsAccounts.getAccount(1));
        
        Assert.equal(woop,10**14*2,"FAIL to changeToken WOOP 2 ");


        Assert.ok(changeToken(TestsAccounts.getAccount(1),10**14,3,false),"FAIL set changeToken WOOP 3");
        
        ( exist, bnb,woop,autoc)=  getValues(TestsAccounts.getAccount(1));
        
        Assert.equal(woop,10**14,"FAIL to changeToken WOOP 3 ");
    
    }



    function testRemoveStake() public {
        
        removeStake(TestsAccounts.getAccount(2));
        
        Assert.equal(getStakeCount(),1,"FAIL removeStake");
    }




    function testSubstractFromStake() public {
        

        stm.substractFromStake(TestsAccounts.getAccount(1), 1);
        
         address accr;uint256 bal;uint256 bnb;uint256 woop;bool autoc;
        ( accr, bal, bnb,woop,autoc)=  getStake(TestsAccounts.getAccount(1));
        
        Assert.equal(bal,(10**18*3)-1,"FAIL substractFromStake");

    }
    

    function testRenewStake()   public {
        
        stm.renewStake(TestsAccounts.getAccount(1), 10**18);

         address accr;uint256 bal;uint256 bnb;uint256 woop;bool autoc;
        ( accr, bal, bnb,woop,autoc)=  getStake(TestsAccounts.getAccount(1));
        
        Assert.equal(bal,10**18,"FAIL renewStake");
        
    }
    
    
    
    function testTransferStake() public{
        
        Assert.ok(stm.transferStake(TestsAccounts.getAccount(1), TestsAccounts.getAccount(3)),"FAIL transferStake");

        Assert.ok(!StakeExist(TestsAccounts.getAccount(1)),"FAIL transferStake acc 1 exist");
        
        Assert.ok(StakeExist(TestsAccounts.getAccount(3)),"FAIL transferStake acc 3 NOT exist");
        
    }
    
    
    
    function testAddMultiplesStakes() public {

        address[] memory accounts=new address[](3);
        uint256[] memory amounts=new uint256[](3);
        uint256[] memory bnbs=new uint256[](3);
        uint256[] memory woops=new uint256[](3);
        bool[] memory autocs=new bool[](3);
        
        accounts[0]=0xAf8C924B61924F64537338F7348000a3223F9C83;amounts[0]=10**18;bnbs[0]=10**14;woops[0]=10**10;autocs[0]=true;
        accounts[1]=0x5d8154f12f5F3cC703FFeE17043DCF701E4a74C3;amounts[1]=10**17;bnbs[1]=0;woops[1]=10**10;autocs[1]=false;
        accounts[2]=0xAf8C924B61924F64537338F7348000a3223F9C83;amounts[2]=10**17;bnbs[2]=10**14;woops[2]=0;autocs[2]=true;
        
        Assert.ok( newStake( accounts, amounts,bnbs, woops, autocs),"FAIL Multiple newStake " );
        
         address accr;uint256 bal;uint256 bnb;uint256 woop;bool autoc;
        ( accr, bal, bnb,woop,autoc)=  getStake(0x5d8154f12f5F3cC703FFeE17043DCF701E4a74C3);
        
        Assert.equal(accr,0x5d8154f12f5F3cC703FFeE17043DCF701E4a74C3,"FAIL Multiple newStake acc");
        Assert.equal(bal,10**17,"FAIL Multiple newStake amount");
        Assert.equal(bnb,0,"FAIL Multiple newStake bnb");
        Assert.equal(woop,10**10,"FAIL Multiple newStake woop");
        Assert.equal(autoc,false,"FAIL Multiple newStake autoc");
        
    }
    
    
    function testRemoveAllStake() public{
        
        Assert.ok(stm.removeAllStake(),"FAIL removeAllStake");
        
        Assert.equal(getStakeCount(),0,"FAIL removeAllStake");
    }
    
}
