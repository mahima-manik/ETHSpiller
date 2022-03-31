// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <0.9.0;

import "./EthSpiller.sol";

contract EthSpillerFactory {
    mapping (address => address) ethSpillers;

    error EthSpillerAlreadyExists (address ethSpillerAddress);
    error EthSpillerDoesNotExist ();

    modifier restricted() {
        if (ethSpillers[msg.sender] == address(0)) { revert EthSpillerDoesNotExist(); }
        _;
   }

    function createEthSpiller() external returns (address) {
        if (ethSpillers[msg.sender] != address(0)) { revert EthSpillerAlreadyExists(ethSpillers[msg.sender]); }

        EthSpiller ethSpiller = new EthSpiller(msg.sender);
        ethSpillers[msg.sender] = ethSpiller.contractAddress();
        return ethSpillers[msg.sender];
    }

    function addRecepient (address account) external restricted returns (uint) {
        address contractAddress = ethSpillers[msg.sender];
        EthSpiller ethSpiller = EthSpiller(contractAddress);
        ethSpiller.addRecepient(msg.sender, account);
        return ethSpiller.recepientsIndex(account);
    }

    function removeRecepient (address account) external restricted {
        address contractAddress = ethSpillers[msg.sender];
        EthSpiller ethSpiller = EthSpiller(contractAddress);
        ethSpiller.removeRecepient(msg.sender, account);
    }

    function receiveEther () external payable restricted {
        address contractAddress = ethSpillers[msg.sender];
        EthSpiller ethSpiller = EthSpiller(contractAddress);
        ethSpiller.receiveEther(msg.value);
    }
}