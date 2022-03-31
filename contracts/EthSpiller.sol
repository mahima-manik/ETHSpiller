// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <0.9.0;

contract EthSpiller {
  address immutable public owner = msg.sender;
  mapping (address => uint) public recepientsIndex;
  address[] public recepients;

	event RecepientAdded(address account);
	event RecepientRemoved(address account);

	error UnauthorizedAccess(address attacker);
    error ElementNotPresent(address account);

  modifier restricted() {
    if (msg.sender != owner) { revert UnauthorizedAccess(msg.sender); }
    _;
  }

  function addRecepient (address account) external restricted {
		
		uint index = recepientsIndex[account];
		
		if (index == 0) {
			recepients.push(account);
			recepientsIndex[account] = recepients.length;
			emit RecepientAdded(account);
		}
  
	}

	function removeRecepient (address account) external restricted {
		
		uint index = recepientsIndex[account];

		if (index == 0) { revert ElementNotPresent(account); }
		
		remove (recepientsIndex[account]-1);
		recepientsIndex[account] = 0;
    emit RecepientRemoved(account);
  }

  function remove(uint _index) private {
		require(_index < recepients.length, "index out of bound");
		
		for (uint i = _index; i < recepients.length - 1; i++) {
			recepients[i] = recepients[i+1];
			recepientsIndex[recepients[i]] = i+1;
		}
		
		recepients.pop();
  }

  receive () external payable {
		uint total = recepients.length;
		uint amount = msg.value / total;
		
		for (uint i=0; i < total; i++) {
			recepients[i].call{value: amount}("");
		}
  }

}

