// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;
import "./REWARDManager.sol";


contract MockREWARDManager is REWARDManager {
    
    
    constructor()  REWARDManager()  public{
        
    }

    function MockaddOwner(address account) external returns(uint256){
        _lastIndexSowners=_lastIndexSowners.add(1);
        _SownersCount=  _SownersCount.add(1);
        
        _Sowners[_lastIndexSowners].account = account;
          _Sowners[_lastIndexSowners].flag = 1;
        
        _IDSownersIndex[account] = _lastIndexSowners;
        
        emit addNewInOwners(account);
        return _lastIndexSowners;
    }       
    
    
    
    
}