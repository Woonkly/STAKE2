// SPDX-License-Identifier: GPL-3.0
    
pragma solidity ^0.6.6;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/WoonckyPOS.sol";




// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testWOOPStake is WOOPStake {


    WOOPStake internal ptm;
    MockStakeManager internal mcstm;
    MockREWARDManager internal mcrm;
    address internal _woop=0x943c5bf93B09aAb282387D4d31f6289CdeB35653;
    address internal _mrm=0xf8e81D47203A594245E36C48e151709F0C19fBe8;
    address internal _ebnb=0x9C278d17Df6f05F6E4d45d7c32c94a059bd82F2B;
    
    constructor() 

        WOOPStake(_mrm,_woop,_ebnb,0xC680D7Cb2Eb97411197C7bEEaf037DE8F3300b4C,0xf0194a8615261ba7c6cC8625D8A3420101Dc73Ea)
    public{
        
    }


    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Here should instantiate tested contract
        
        address st=0xd9145CCE52D386f254917e481eB44e9943F39138;
        newInOwners(address(this));
        ptm=WOOPStake(address(this));
        mcstm= MockStakeManager(st);
        mcstm.MockaddOwner(address(this));
        _cstm= MockStakeManager(st);
        _stm=st;
        
        mcrm=MockREWARDManager(_mrm);
        mcrm.MockaddOwner(address(this));
        
        
    }


/*
    function testMigrateSTM() public{
        
        Assert.equal(msg.sender, TestsAccounts.getAccount(4), "wrong sender in checkSetPaused is not account-4");        
        
        address acc=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        
        ptm.migrateSTKM(acc,10**19,0, 0, false);
        
        Assert.equal(_cstm.getStakeCount(),1,"FAIL migrateSTKM");
        
        (address accr,uint256 bal,uint256 bnb,uint256 woop,bool autoc)= _cstm.getStake(acc);
        
        Assert.equal(accr,acc,"FAIL migrateSTKM acc");
        Assert.equal(bal,10**19,"FAIL migrateSTKM liq");
        Assert.equal(bnb,0,"FAIL migrateSTKM bnb");
        Assert.equal(woop,0,"FAIL migrateSTKM woop");
        Assert.equal(autoc,false,"FAIL migrateSTKM isAutoC");
        

    }

*/

/*
    function testProcessRewards() public{
        
        
     //   Assert.ok(processReward(_woop, 10**18),"FAIL processReward");
     
     uint256 rew=1000000000000000000;
     uint256 dealed= processBlockReward(_woop,0, rew,1,2);
     //dealed+= processBlockReward(_woop, rew,3,4);
     
     Assert.equal(dealed,1,"LOOK dealed ");
     
     
    }
*/


function testGestStadistics() public{
     (uint256 ind,uint256 funds,uint256 rews,uint256 rewc,uint256 autoc)=  getStatistics(_woop);
     Assert.equal(ind,4,"FAIL  testGestStadistics ");
}


/*
    function testAddMultiplesStakes() public {

        address[] memory accounts=new address[](3);
        uint256[] memory amounts=new uint256[](3);
        uint256[] memory bnbs=new uint256[](3);
        uint256[] memory woops=new uint256[](3);
        bool[] memory autocs=new bool[](3);
        
        accounts[0]=0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;amounts[0]=10**19;bnbs[0]=0;woops[0]=0;autocs[0]=false;
        accounts[1]=0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;amounts[1]=10**19;bnbs[1]=0;woops[1]=0;autocs[1]=false;
        accounts[2]=0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;amounts[2]=10**19;bnbs[2]=0;woops[2]=0;autocs[2]=false;
        
        Assert.ok( migrateSTKM( accounts, amounts,bnbs, woops, autocs),"FAIL Multiple newStake " );
        
         address accr;uint256 bal;uint256 bnb;uint256 woop;bool autoc;
        ( accr, bal, bnb,woop,autoc)=  _cstm.getStake(0x5d8154f12f5F3cC703FFeE17043DCF701E4a74C3);
        
        Assert.equal(accr,0x5d8154f12f5F3cC703FFeE17043DCF701E4a74C3,"FAIL Multiple newStake acc");
        Assert.equal(bal,10**19,"FAIL Multiple newStake amount");
        Assert.equal(bnb,0,"FAIL Multiple newStake bnb");
        Assert.equal(woop,0,"FAIL Multiple newStake woop");
        Assert.equal(autoc,false,"FAIL Multiple newStake autoc");
        
    }
    
*/



/*    
    /// #sender: account-2
    function testWithdrawReward() public {

        (bool exist,,uint256 rew)=_crtm.getReward( msg.sender,_woop);
        
        Assert.equal(msg.sender, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, "wrong sender in checkSetPaused is not account-2");        

        Assert.ok(WithdrawReward(_woop, rew),"FAIL WithdrawReward");
        
        ( exist,, rew)=_crtm.getReward( msg.sender,_woop);
        
        Assert.equal(rew,0,"FAIL testWithdrawReward");
        
        
        
    }
    
*/


/*

    /// #sender: account-2    
    function testSetCompound() public{

        Assert.equal(msg.sender, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, "wrong sender in checkSetPaused is not account-2");        

        (bool exist,,uint256 rew)=_crtm.getReward(msg.sender,_woop);
        
         address accr;uint256 bal;uint256 bnb;uint256 woop;bool autoc;
        ( accr, bal, bnb,woop,autoc)=  _cstm.getStake(msg.sender);

        Assert.ok(CompoundReward(rew),"FAIL CompoundReward");
        
        uint256 bal2=0;
        ( accr, bal2, bnb,woop,autoc)= _cstm.getStake(msg.sender);
        
        Assert.equal(bal+rew, bal2,"FAIL CompoundReward set");
        
        ( exist,, rew)=_crtm.getReward(msg.sender,_woop);
        
        Assert.equal(rew,0,"FAIL CompoundReward reset reward");
        
    }
    
    
    /// #sender: account-2    
    function testAutoCompound() public{
        Assert.equal(msg.sender, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, "wrong sender in checkSetPaused is not account-2");        
        
        
        (bool exist,,uint256 rew)=_crtm.getReward(msg.sender,_woop);
        
         address accr;uint256 bal;uint256 bnb;uint256 woop;bool autoc;
        ( accr, bal, bnb,woop,autoc)=  _cstm.getStake(msg.sender);


        Assert.ok(setMyCompoundStatus(true),"FAIL setMyCompoundStatus");
        
        uint256 bal2=0;
        bool autoc2=false;
        ( accr, bal2, bnb,woop,autoc2)= _cstm.getStake(msg.sender);
        
        Assert.equal(autoc2,true,"FAIL setMyCompoundStatus status");
        
        
        Assert.equal(bal+rew, bal2,"FAIL CompoundReward set");
        
        ( exist,, rew)=_crtm.getReward(msg.sender,_woop);
        
        Assert.equal(rew,0,"FAIL CompoundReward reset reward");

        
    }
    
    */
    
    
    
    function removeOwnerFromSTM() public{
        //mcstm.removeAllStake();
        mcstm.removeFromOwners(address(this));
        
        mcrm.removeFromOwners(address(this));
    }
    
}
