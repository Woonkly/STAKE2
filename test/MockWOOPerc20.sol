// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;


import "https://github.com/Woonkly/OpenZeppelinBaseContracts/contracts/token/ERC20/ERC20.sol";


contract WOOPS is ERC20 {

  constructor() ERC20("WOOP","WOOP") public {

      _mint(msg.sender,10000000000*10**18);
  }
  

  
}
