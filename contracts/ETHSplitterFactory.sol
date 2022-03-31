// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <0.9.0;

import "./EthSpitter.sol";

contract EthSpitterFactory {
    mapping (address => address) ethSpitters;

    error EthSpitterAlreadyExists (address ethSpitterAddress);
    error EthSpitterDoesNotExist ();

    modifier restricted() {
        if (ethSpitters[msg.sender] == address(0)) { revert EthSpitterDoesNotExist(); }
        _;
   }

    function createEthSpitter() external returns (address) {
        if (ethSpitters[msg.sender] != address(0)) { revert EthSpitterAlreadyExists(ethSpitters[msg.sender]); }

        EthSpitter ethSpitter = new EthSpitter(msg.sender);
        ethSpitters[msg.sender] = ethSpitter.contractAddress();
        return ethSpitters[msg.sender];
    }

    function addRecepient (address account) external restricted returns (uint) {
        address contractAddress = ethSpitters[msg.sender];
        EthSpitter ethSpitter = EthSpitter(contractAddress);
        ethSpitter.addRecepient(msg.sender, account);
        return ethSpitter.recepientsIndex(account);
    }

    function removeRecepient (address account) external restricted {
        address contractAddress = ethSpitters[msg.sender];
        EthSpitter ethSpitter = EthSpitter(contractAddress);
        ethSpitter.removeRecepient(msg.sender, account);
    }

    function receiveEther () external payable restricted {
        address contractAddress = ethSpitters[msg.sender];
        EthSpitter ethSpitter = EthSpitter(contractAddress);
        ethSpitter.receiveEther{value: msg.value}();
    }
}