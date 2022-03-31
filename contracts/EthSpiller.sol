// SPDX-License-Identifier: MIT
pragma solidity >0.6.0 <0.9.0;

contract EthSpiller {
  address immutable public owner;
  address immutable public contractAddress;
  mapping (address => uint) public recepientsIndex;
  address[] public recepients;

	event RecepientAdded(address account);
	event RecepientRemoved(address account);

	error UnauthorizedAccess(address attacker);
    error ElementNotPresent(address account);

  modifier restricted(address _owner) {
    if (_owner != owner) { revert UnauthorizedAccess(_owner); }
    _;
  }

    constructor (address _owner)	{
        owner = _owner;
        contractAddress = address(this);
    }

  function addRecepient (address _owner, address account) external restricted(_owner) {
		uint index = recepientsIndex[account];
		if (index == 0) {
			recepients.push(account);
			recepientsIndex[account] = recepients.length;
			emit RecepientAdded(account);
		}
  }

	function removeRecepient (address _owner, address account) external restricted(_owner) {
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

  function receiveEther (uint amount) external payable {
      uint total = recepients.length;
      uint val = amount / total;
      for (uint i=0; i < total; i++) {
        recepients[i].call{value: val}("");
      }
  }
}