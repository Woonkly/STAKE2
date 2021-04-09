// SPDX-License-Identifier: MIT

/**
MIT License

Copyright (c) 2021 Woonkly OU

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED BY WOONKLY OU "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/

pragma solidity ^0.6.6;

import "https://github.com/Woonkly/OpenZeppelinBaseContracts/contracts/math/SafeMath.sol";
import "https://github.com/Woonkly/OpenZeppelinBaseContracts/contracts/token/ERC20/ERC20.sol";
import "https://github.com/Woonkly/MartinHSolUtils/Owners.sol";

contract REWARDManager is Owners {
    using SafeMath for uint256;

    //Section Type declarations

    struct Stake {
        address account;
        mapping(address => uint256) rewards;
        uint8 flag; //0 no exist  1 exist 2 deleted
    }

    //Section State variables
    uint256 internal _lastIndexStakes;
    mapping(uint256 => Stake) internal _Stakes;
    mapping(address => uint256) internal _IDStakesIndex;
    uint256 internal _StakeCount;

    address[] internal SCs;

    //Section Modifier
    modifier onlyNewStake(address account) {
        require(!this.StakeExist(account), "1");
        _;
    }

    modifier onlyStakeExist(address account) {
        require(StakeExist(account), "1");
        _;
    }

    modifier onlyStakeIndexExist(uint256 index) {
        require(StakeIndexExist(index), "1");
        _;
    }

    //Section Events
    event addNewStake(address account, address sc, uint256 amount);
    event RewaredChanged(
        address account,
        address sc,
        uint256 amount,
        uint8 set
    );

    event StakeReNewed(
        address account,
        address sc,
        uint256 oldAmount,
        uint256 newAmount
    );

    event StakeRemoved(address account);
    event StakeSubstracted(
        address account,
        address sc,
        uint256 oldAmount,
        uint256 subAmount,
        uint256 newAmount
    );
    event AllStakeRemoved();

    //Section functions

    constructor() public {
        _lastIndexStakes = 0;
        _StakeCount = 0;
    }

    function _getSCIndex(address sc) internal view returns (bool, uint256) {
        if (SCs.length == 0) return (false, 0);

        for (uint256 i = 0; i < SCs.length; i++) {
            if (SCs[i] == sc) {
                return (true, i);
            }
        }
        return (false, 0);
    }

    function _manageSCs(address sc) internal {
        (bool exist, ) = _getSCIndex(sc);
        if (!exist) {
            SCs.push(sc);
        }
    }

    function getSCs() external view returns (address[] memory) {
        return (SCs);
    }

    function _newStake(
        address account,
        address sc,
        uint256 amount
    ) internal returns (uint256) {
        _lastIndexStakes = _lastIndexStakes.add(1);
        _StakeCount = _StakeCount.add(1);

        _Stakes[_lastIndexStakes].account = account;
        _Stakes[_lastIndexStakes].rewards[sc] = amount;
        _Stakes[_lastIndexStakes].flag = 1;

        _IDStakesIndex[account] = _lastIndexStakes;

        _manageSCs(sc);

        emit addNewStake(account, sc, amount);
        return _lastIndexStakes;
    }

    function newStake(
        address account,
        address sc,
        uint256 amount
    ) public onlyIsInOwners onlyNewStake(account) returns (uint256) {
        return _newStake(account, sc, amount);
    }

    function changeToken(
        address account,
        address sc,
        uint256 amount,
        uint8 set
    ) public onlyIsInOwners onlyStakeExist(account) returns (bool) {
        _manageSCs(sc);

        if (set == 1) {
            _Stakes[_IDStakesIndex[account]].rewards[sc] = amount;
        }

        if (set == 2) {
            _Stakes[_IDStakesIndex[account]].rewards[sc] = _Stakes[
                _IDStakesIndex[account]
            ]
                .rewards[sc]
                .add(amount);
        }

        if (set == 3) {
            _Stakes[_IDStakesIndex[account]].rewards[sc] = _Stakes[
                _IDStakesIndex[account]
            ]
                .rewards[sc]
                .sub(amount);
        }

        emit RewaredChanged(account, sc, amount, set);

        return true;
    }

    function manageStake(
        address account,
        address sc,
        uint256 amount
    ) public onlyIsInOwners returns (bool) {
        if (!StakeExist(account)) {
            newStake(account, sc, amount);
        } else {
            changeToken(account, sc, amount, 2);
        }

        return true;
    }

    function getStake(address account)
        public
        view
        returns (
            bool,
            address[] memory,
            uint256[] memory
        )
    {
        address[] memory s = new address[](0);
        uint256[] memory rw = new uint256[](0);

        if (!StakeExist(account) || SCs.length == 0) return (false, s, rw);

        uint256[] memory r = new uint256[](SCs.length);

        for (uint256 i = 0; i < SCs.length; i++) {
            r[i] = _Stakes[_IDStakesIndex[account]].rewards[SCs[i]];
        }

        return (true, SCs, r);
    }

    function getStake(address account, address sc)
        public
        view
        returns (
            bool,
            bool,
            uint256
        )
    {
        (bool exist, ) = _getSCIndex(sc);

        if (!StakeExist(account) || !exist) return (false, exist, 0);

        return (true, true, _Stakes[_IDStakesIndex[account]].rewards[sc]);
    }

    function getStakeByIndex(uint256 index)
        public
        view
        returns (
            bool,
            address[] memory,
            uint256[] memory
        )
    {
        address[] memory s = new address[](0);
        uint256[] memory rw = new uint256[](0);

        if (!StakeIndexExist(index) || SCs.length == 0) return (false, s, rw);

        uint256[] memory rwds = new uint256[](SCs.length);

        for (uint256 i = 0; i < SCs.length; i++) {
            rwds[i] = _Stakes[index].rewards[SCs[i]];
        }

        return (true, SCs, rwds);
    }

    function getStakeByIndex(uint256 index, address sc)
        public
        view
        returns (
            bool,
            bool,
            uint256
        )
    {
        (bool exist, ) = _getSCIndex(sc);

        if (!StakeIndexExist(index) || !exist) return (false, exist, 0);

        return (true, true, _Stakes[index].rewards[sc]);
    }

    function getAllStake()
        public
        view
        returns (uint256[] memory, address[] memory)
    {
        uint256[] memory indexs = new uint256[](_StakeCount);
        address[] memory pACCs = new address[](_StakeCount);

        uint256 ind = 0;

        for (uint32 i = 0; i < (_lastIndexStakes + 1); i++) {
            Stake memory p = _Stakes[i];
            if (p.flag == 1) {
                indexs[ind] = i;
                pACCs[ind] = p.account;
                ind++;
            }
        }

        return (indexs, pACCs);
    }

    function transferStake(address origin, address destination)
        external
        onlyIsInOwners
        returns (bool)
    {
        require(StakeExist(origin), "1");
        require(SCs.length > 0, "2");

        uint256 rwd;

        for (uint256 i = 0; i < SCs.length; i++) {
            (, , rwd) = getStake(origin, SCs[i]);

            manageStake(destination, SCs[i], rwd);
        }

        removeStake(origin);

        return true;
    }

    function getStakeCount() public view returns (uint256) {
        return _StakeCount;
    }

    function getLastIndexStakes() public view returns (uint256) {
        return _lastIndexStakes;
    }

    function StakeExist(address account) public view returns (bool) {
        return _StakeExist(_IDStakesIndex[account]);
    }

    function StakeIndexExist(uint256 index) public view returns (bool) {
        return (index < (_lastIndexStakes + 1));
    }

    function _StakeExist(uint256 StakeID) internal view returns (bool) {
        return (_Stakes[StakeID].flag == 1);
    }

    function renewStake(
        address account,
        address sc,
        uint256 newAmount
    ) external onlyIsInOwners onlyStakeExist(account) returns (uint256) {
        (, bool scexist, uint256 rwd) = getStake(account, sc);

        require(scexist, "1");

        changeToken(account, sc, newAmount, 1);

        emit StakeReNewed(account, sc, rwd, newAmount);

        return _IDStakesIndex[account];
    }

    function removeStake(address account)
        public
        onlyIsInOwners
        onlyStakeExist(account)
    {
        _Stakes[_IDStakesIndex[account]].flag = 2;
        _Stakes[_IDStakesIndex[account]].account = address(0);

        for (uint256 i = 0; i < SCs.length; i++) {
            _Stakes[_IDStakesIndex[account]].rewards[SCs[i]] = 0;
        }

        _StakeCount = _StakeCount.sub(1);
        emit StakeRemoved(account);
    }

    function substractFromStake(
        address account,
        address sc,
        uint256 subAmount
    ) external onlyIsInOwners onlyStakeExist(account) returns (uint256) {
        (, bool scexist, uint256 oldAmount) = getStake(account, sc);

        require(scexist, "1");

        if (oldAmount == 0) {
            return _IDStakesIndex[account];
        }

        require(subAmount <= oldAmount, "1");

        changeToken(account, sc, subAmount, 3);

        emit StakeSubstracted(
            account,
            sc,
            oldAmount,
            subAmount,
            oldAmount.sub(subAmount)
        );

        return _IDStakesIndex[account];
    }

    function getReward(address account, address sc)
        public
        view
        returns (
            bool,
            bool,
            uint256
        )
    {
        (bool exist, ) = _getSCIndex(sc);

        if (!StakeExist(account) || !exist) return (false, exist, 0);

        return (true, exist, _Stakes[_IDStakesIndex[account]].rewards[sc]);
    }

    function removeAllStake() external onlyIsInOwners returns (bool) {
        for (uint32 i = 0; i < (_lastIndexStakes + 1); i++) {
            _IDStakesIndex[_Stakes[i].account] = 0;
            _Stakes[i].flag = 0;
            _Stakes[i].account = address(0);

            for (uint256 j = 0; j < SCs.length; j++) {
                _Stakes[i].rewards[SCs[j]] = 0;
            }
        }
        _lastIndexStakes = 0;
        _StakeCount = 0;
        emit AllStakeRemoved();
        return true;
    }
}
