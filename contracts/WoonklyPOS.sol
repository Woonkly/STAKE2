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
import "https://github.com/Woonkly/OpenZeppelinBaseContracts/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/Woonkly/MartinHSolUtils/PausabledLMH.sol";
import "https://github.com/Woonkly/STAKESmartContractPreRelease/IInvestiable.sol";
import "../test/REWARDManager.sol";
import "../test/STAKEManager.sol";

//import "./MockStakeManager.sol";  add only for test
//import "./MockREWARDManager.sol"; add only for test

contract WOOPStake is PausabledLMH, ReentrancyGuard {
    using SafeMath for uint256;

    //Section Type declarations
    struct processRewardInfo {
        uint256 remainder;
        uint256 woopsRewards;
        uint256 dealed;
        address me;
        bool resp;
    }

    struct Stake {
        address account;
        bool autoCompound;
        uint256 bal;
        uint256 bnb;
        uint256 woop;
        uint8 flag; //0 no exist  1 exist 2 deleted
    }

    struct Stadistic {
        uint256 ind;
        uint256 funds;
        uint256 rews;
        uint256 rewsCOIN;
        uint256 autocs;
    }

    //Section State variables
    address internal _stm;
    address internal _rm;
    REWARDManager internal _crtm;
    STAKEManager internal _cstm;
    uint256 internal _factor;
    address internal _woopERC20;
    address internal _bnbEMULATE;
    address internal _remainder;
    mapping(address => uint256) internal _distributeds;
    mapping(address => uint256) internal _operations;
    mapping(address => mapping(address => uint256)) private _rewardsSubstracted;
    address internal _investable;
    IInvestable internal _inv;

    //Section Modifier

    //Section Events
    event StakeAddrChanged(address old, address news);
    event RmAddrChanged(address old, address news);
    event FactorChanged(uint256 oldf, uint256 newf);
    event ERC20WOOPChanged(address old, address newr);
    event DistributedReseted(address sc, uint256 old);
    event InsuficientRewardFund(address sc, address account);
    event NewLeftover(address sc, uint256 leftover);
    event AutoCompoundAdded(address account, uint256 amountAdded);
    event CoinReceived(uint256 coins);
    event RemaninderAccChanged(address old, address newr);
    event VestingChanged(address old, address newi);
    event WithdrawFunds(address account, uint256 amount, uint256 remainder);
    event RewardWithdrawed(
        address sc,
        address account,
        uint256 amount,
        uint256 remainder
    );
    event RewardToCompound(address account, uint256 amount);
    event RewardCOINWithdrawed(
        address account,
        uint256 amount,
        uint256 remainder
    );
    event StakeClosed(uint256[] balERC20, uint256 balWOOP, uint256 balCOIN);

    //Section functions

    constructor(
        address rtm,
        address woopERC20,
        address bnbEMULATE,
        address operation,
        address inv,
        address stm
    ) public {
        _crtm = REWARDManager(rtm);
        _rm = rtm;
        _factor = 100000000;
        _woopERC20 = woopERC20;
        _bnbEMULATE = bnbEMULATE;
        _remainder = operation;
        _investable = inv;
        _inv = IInvestable(inv);
        _stm = stm;
        _cstm = STAKEManager(stm);
    }

    function getAllERC20()
        external
        view
        returns (uint256[] memory, address[] memory)
    {
        address[] memory pACCs = _crtm.getSCs();

        uint256[] memory indexs = new uint256[](_crtm.getSCs().length);

        for (uint256 i = 0; i < pACCs.length; i++) {
            indexs[i] = i;
        }

        return (indexs, pACCs);
    }

    function getERC20Count() external view returns (uint256) {
        return _crtm.getSCs().length;
    }

    function rewardedCOIN(address account) public view returns (uint256) {
        (, , uint256 reward) = _crtm.getReward(account, _bnbEMULATE);
        return reward;
    }

    function rewarded(address sc, address account)
        public
        view
        returns (uint256)
    {
        (, , uint256 reward) = _crtm.getReward(account, sc);
        return reward;
    }

    receive() external payable {
        emit CoinReceived(msg.value);
    }

    fallback() external payable {}

    function getMyCoinBalance() public view returns (uint256) {
        address payable self = address(this);
        uint256 bal = self.balance;
        return bal;
    }

    function getMyTokensBalance(address sc) public view returns (uint256) {
        IERC20 _token = IERC20(sc);
        return _token.balanceOf(address(this));
    }

    function getTokensBalanceOf(address sc, address account)
        public
        view
        returns (uint256)
    {
        IERC20 _token = IERC20(sc);
        return _token.balanceOf(account);
    }

    function getStakeAddr() public view returns (address) {
        return _stm;
    }

    function setStakeAddr(address news) public onlyIsInOwners returns (bool) {
        require(news != address(0), "1");
        address old = _stm;
        _stm = news;
        _cstm = STAKEManager(news);
        emit StakeAddrChanged(old, news);
        return true;
    }

    function getRmAddr() public view returns (address) {
        return _rm;
    }

    function setRmAddr(address news) public onlyIsInOwners returns (bool) {
        require(news != address(0), "1");
        address old = _rm;
        _rm = news;
        _crtm = REWARDManager(_rm);

        emit RmAddrChanged(old, news);
        return true;
    }

    function getCoinEMULATE() public view returns (address) {
        return _bnbEMULATE;
    }

    function setFactor(uint256 newf) public onlyIsInOwners {
        require(newf <= 1000000000, ">lim");
        emit FactorChanged(_factor, newf);
        _factor = newf;
    }

    function getFactor() public view returns (uint256) {
        return _factor;
    }

    function getfractionUnit() public view returns (uint256) {
        return uint256(1000000000000000000000000000).div(_factor);
    }

    function getERC20WOOP() public view returns (address) {
        return _woopERC20;
    }

    function setERC20WOOP(address newr) public onlyIsInOwners returns (bool) {
        require(newr != address(0), "!0ad");
        address old = _woopERC20;
        _woopERC20 = newr;
        emit ERC20WOOPChanged(old, newr);
        return true;
    }

    function getDistributed(address sc) public view returns (uint256) {
        return _distributeds[sc];
    }

    function resetDistributed(address sc) public onlyIsInOwners returns (bool) {
        uint256 old = _distributeds[sc];
        _distributeds[sc] = 0;
        emit DistributedReseted(sc, old);
        return true;
    }

    function getDistributedCOIN() public view returns (uint256) {
        return _distributeds[_bnbEMULATE];
    }

    function getVesting() public view returns (address) {
        return _investable;
    }

    function setVesting(address newi) public onlyIsInOwners returns (bool) {
        require(newi != address(0), "!0ad");
        address old = _investable;
        _investable = newi;
        _inv = IInvestable(newi);
        emit VestingChanged(old, newi);
        return true;
    }

    function getRemaninderAcc() public view returns (address) {
        return _remainder;
    }

    function setRemaniderAcc(address newr)
        public
        onlyIsInOwners
        returns (bool)
    {
        require(newr != address(0), "!0ad");
        address old = _remainder;
        _remainder = newr;
        emit RemaninderAccChanged(old, newr);
        return true;
    }

    function setMyCompoundStatus(bool status)
        public
        nonReentrant
        returns (bool)
    {
        (address acc, uint256 fund, , , ) = _cstm.getStake(_msgSender());
        require(acc != address(0), "1");

        _cstm.setAutoCompound(_msgSender(), status);

        (bool exist, , uint256 rew) = _crtm.getStake(_msgSender(), _woopERC20);

        if (status == true && exist && fund > 0 && rew > 0) {
            _compoundReward(_msgSender(), rew);
        }

        return true;
    }

    function _addStake(address account, uint256 amount)
        internal
        returns (bool)
    {
        return _cstm.manageStake(account, amount);
    }

    function addStake(uint256 amount) public nonReentrant returns (bool) {
        require(!isPaused(), "1");
        IERC20 _token = IERC20(_woopERC20);
        require(_token.allowance(_msgSender(), address(this)) >= amount, "2");

        require(amount >= getfractionUnit(), "3");

        require(_token.transferFrom(_msgSender(), address(this), amount), "4");

        require(_addStake(_msgSender(), amount), "5");

        return true;
    }

    function _withdrawFunds(address account, uint256 amount)
        internal
        returns (uint256)
    {
        require(!isPaused(), "1");
        require(_cstm.StakeExist(account), "2");

        (, uint256 fund, , , ) = _cstm.getStake(account);

        require(amount <= fund, "3");

        uint256 remainder = fund.sub(amount);

        if (remainder == 0) {
            _cstm.removeStake(account);
        } else {
            _cstm.renewStake(account, remainder);
        }

        emit WithdrawFunds(account, amount, remainder);

        return amount;
    }

    function withdrawFunds(uint256 amount) public nonReentrant returns (bool) {
        require(!isPaused(), "1");
        require(_cstm.StakeExist(_msgSender()), "2");
        require(
            _inv.canWithdrawFunds(
                _msgSender(),
                amount,
                _cstm.balanceOf(_msgSender())
            ),
            "3"
        );

        IERC20 _token = IERC20(_woopERC20);

        require(_token.transfer(_msgSender(), amount), "4");
        _withdrawFunds(_msgSender(), amount);
        _inv.updateFund(_msgSender(), amount);
        return true;
    }

    function migrateSTKM(
        address account,
        uint256 liq,
        uint256 bnb,
        uint256 woop,
        bool isAutoc
    ) public onlyIsInOwners returns (bool) {
        require(_stm != address(0), "1");
        require(!isPaused(), "2");

        _cstm.newStake(account, liq, bnb, woop, isAutoc);

        return true;
    }

    function migrateSTKM(
        address[] memory accounts,
        uint256[] memory amounts,
        uint256[] memory bnbs,
        uint256[] memory woops,
        bool[] memory autocs
    ) public onlyIsInOwners returns (bool) {
        require(accounts.length > 0, "0");
        require(accounts.length == amounts.length, "1");
        require(accounts.length == bnbs.length, "2");
        require(accounts.length == woops.length, "3");
        require(accounts.length == autocs.length, "4");

        require(_stm != address(0), "5");
        require(!isPaused(), "6");

        return _cstm.newStake(accounts, amounts, bnbs, woops, autocs);
    }

    function calcReward(uint256 amount, uint256 factor)
        public
        view
        returns (uint256)
    {
        return amount.mul(factor).div(_factor);
    }

    function getCalcRewardAmount(address account, uint256 amount)
        public
        view
        returns (uint256, uint256)
    {
        if (!_cstm.StakeExist(account)) return (0, 0);

        (, uint256 fund, , , ) = _cstm.getStake(account);

        if (fund < getfractionUnit()) return (0, 0);

        uint256 factor = fund.div(getfractionUnit());

        if (factor < 1) return (0, 0);

        uint256 remainder = fund.sub(factor.mul(getfractionUnit()));

        uint256 woopsRewards = calcReward(amount, factor);

        if (woopsRewards < 1) return (0, 0);

        return (woopsRewards, remainder);
    }

    function transferReward(address sc, uint256 amount)
        public
        nonReentrant
        returns (bool)
    {
        require(!isPaused(), "1");

        IERC20 _token = IERC20(sc);
        require(_token.allowance(_msgSender(), address(this)) >= amount, "2");

        require(_token.transferFrom(_msgSender(), address(this), amount), "3");

        return true;
    }

    function transferLeftOver(
        address sc,
        uint256 amount,
        bool isCOIN
    ) public onlyIsInOwners nonReentrant returns (bool) {
        require(!isPaused(), "1");

        if (isCOIN) {
            address payable ow = address(uint160(_remainder));
            ow.transfer(amount);
            return true;
        }

        IERC20 _token = IERC20(sc);
        require(_token.transfer(_remainder, amount), "2");
        return true;
    }

    function _dealBlockReward(
        address sc,
        uint256 amount,
        uint256 distributed,
        uint256 indFrom,
        uint256 indTo
    ) internal returns (uint256) {
        require(_stm != address(0), "1");
        require(indFrom <= indTo, "2");

        uint256 last = _cstm.getLastIndexStakes();
        require(indTo <= last, "3");

        processRewardInfo memory slot;

        Stake memory p;

        for (uint256 i = indFrom; i < (indTo + 1); i++) {
            (p.account, p.bal, p.bnb, p.woop, p.autoCompound) = _cstm
                .getStakeByIndex(i);

            if (p.account != address(0) && p.bal > 0) {
                (slot.woopsRewards, slot.remainder) = getCalcRewardAmount(
                    p.account,
                    amount
                );
                if (slot.woopsRewards > 0) {
                    if (
                        _cstm.getAutoCompoundStatus(p.account) &&
                        sc == _woopERC20
                    ) {
                        _cstm.addToStake(p.account, slot.woopsRewards);
                        _crtm.manageStake(p.account, sc, 0);
                        emit AutoCompoundAdded(p.account, slot.woopsRewards);
                    } else {
                        _crtm.manageStake(p.account, sc, slot.woopsRewards);
                    }

                    slot.dealed = slot.dealed.add(slot.woopsRewards);

                    if (amount < (distributed + slot.dealed)) {
                        emit InsuficientRewardFund(sc, p.account);
                        return 0;
                    }
                } else {
                    _crtm.manageStake(p.account, sc, 0);
                }
            }
        } //for

        _distributeds[sc] = _distributeds[sc].add(slot.dealed);

        return slot.dealed;
    }

    function processBlockReward(
        address sc,
        uint256 amount,
        uint256 distributed,
        uint256 indFrom,
        uint256 indTo
    ) public onlyIsInOwners nonReentrant returns (uint256) {
        require(!isPaused(), "2");

        return _dealBlockReward(sc, amount, distributed, indFrom, indTo);
    }

    function _withdrawReward(
        address sc,
        address account,
        uint256 amount
    ) internal returns (uint256) {
        (bool exist, , uint256 rew) = _crtm.getStake(account, sc);

        require(exist, "1");
        require(amount <= rew, "2");

        IERC20 _token = IERC20(sc);
        require(_token.transfer(account, amount), "3");

        _crtm.substractFromStake(account, sc, amount);

        emit RewardWithdrawed(sc, account, amount, rew.sub(amount));

        return amount;
    }

    function WithdrawReward(address sc, uint256 amount)
        public
        nonReentrant
        returns (bool)
    {
        require(!isPaused(), "1");
        _withdrawReward(sc, _msgSender(), amount);

        return true;
    }

    function _withdrawRewardCOIN(address account, uint256 amount)
        internal
        returns (uint256)
    {
        (bool exist, , uint256 rew) = _crtm.getStake(account, _bnbEMULATE);

        require(exist, "1");
        require(amount <= rew, "2");
        require(amount <= getMyCoinBalance(), "3");

        _crtm.substractFromStake(account, _bnbEMULATE, amount);

        address payable acc = address(uint160(address(account)));

        acc.transfer(amount);

        emit RewardCOINWithdrawed(account, amount, rew.sub(amount));

        return amount;
    }

    function WithdrawRewardCOIN(uint256 amount)
        public
        nonReentrant
        returns (bool)
    {
        require(!isPaused(), "1");

        _withdrawRewardCOIN(_msgSender(), amount);

        return true;
    }

    function _compoundReward(address account, uint256 amount)
        internal
        returns (uint256)
    {
        (bool exist, , uint256 rew) = _crtm.getStake(account, _woopERC20);

        require(exist, "1");
        require(amount <= rew, "2");
        require(amount <= getMyTokensBalance(_woopERC20), "3");

        _crtm.substractFromStake(account, _woopERC20, amount);

        _cstm.addToStake(account, amount);

        emit RewardToCompound(account, amount);

        return amount;
    }

    function CompoundReward(uint256 amount) public nonReentrant returns (bool) {
        require(!isPaused(), "1");
        _compoundReward(_msgSender(), amount);

        return true;
    }

    function closeStake() public onlyIsInOwners nonReentrant returns (bool) {
        require(!isPaused(), "1");

        address[] memory erc20s = _crtm.getSCs();
        uint256[] memory balERC20s = new uint256[](erc20s.length);
        IERC20 _token;

        for (uint256 i = 0; i < erc20s.length; i++) {
            _token = IERC20(erc20s[i]);

            balERC20s[i] = getMyTokensBalance(erc20s[i]);
            if (balERC20s[i] > 0) {
                require(_token.transfer(_remainder, balERC20s[i]), "2");
            }
        }

        _token = IERC20(_woopERC20);
        uint256 balWOOP = getMyTokensBalance(_woopERC20);
        if (balWOOP > 0) {
            require(_token.transfer(_remainder, balWOOP), "2");
        }

        uint256 balCOIN = getMyCoinBalance();
        address payable ow = address(uint160(_remainder));
        if (balCOIN > 0) {
            ow.transfer(balCOIN);
        }
        setPause(true);

        emit StakeClosed(balERC20s, balWOOP, balCOIN);
        return true;
    }

    function getSolvencyCOIN() public view returns (bool, uint256) {
        uint256 ind = 0;
        uint256 funds = 0;
        uint256 rews = 0;
        uint256 rewsc = 0;
        uint256 autos = 0;

        (ind, funds, rews, rewsc, autos) = getStatistics(_woopERC20);

        uint256 coins = getMyCoinBalance();

        if (coins < rewsc) {
            return (false, rewsc - coins);
        } else {
            return (true, coins - rewsc);
        }
    }

    function getSolvency(address sc) public view returns (bool, uint256) {
        Stadistic memory s;

        (s.ind, s.funds, s.rews, , ) = getStatistics(sc);

        uint256 tokens = getMyTokensBalance(sc);

        uint256 tot = s.funds + s.rews;

        if (tokens < tot) {
            return (false, tot - tokens);
        } else {
            return (true, tokens - tot);
        }
    }

    function getStatistics(address sc)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Stadistic memory s;
        Stake memory p;

        uint256 last = _cstm.getLastIndexStakes();

        for (uint256 i = 0; i < (last + 1); i++) {
            (p.account, p.bal, p.bnb, p.woop, p.autoCompound) = _cstm
                .getStakeByIndex(i);

            if (p.account != address(0)) {
                if (sc == _woopERC20) {
                    s.funds = s.funds.add(p.bal);
                }

                s.rews = s.rews.add(rewarded(sc, p.account));

                s.rewsCOIN = s.rewsCOIN.add(rewardedCOIN(p.account));

                if (p.autoCompound) {
                    s.autocs++;
                }
                s.ind++;
            }
        }

        return (s.ind, s.funds, s.rews, s.rewsCOIN, s.autocs);
    }
}
