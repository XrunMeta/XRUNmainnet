/**
 *Submitted for verification at Etherscan.io on 2019-05-13
*/
pragma solidity ^0.8.11;

import "./IXRUN.sol";

contract XRUN_ERC20 is IXRUN {
	string public name;
	string public symbol;
	uint8 public decimals = 18;
	uint256 public totalSupply;
	uint256 public TimeNow;

	address public owner;
	mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) public allowance;
	mapping (address => bool) public frozen;
	mapping (address => uint256) public limitation;
	mapping (address => uint256) public limitUntil;

	mapping (address => bool) public administrators;

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event Burn(address indexed from, uint256 value);

	

	constructor(
		uint256 initialSupply,
		string memory tokenName,
		string memory tokenSymbol
	)  {
		totalSupply = initialSupply * 10 ** uint256(decimals);
		balanceOf[msg.sender] = totalSupply;
		name = tokenName;
		symbol = tokenSymbol;
        administrators[msg.sender] = true;
		owner = msg.sender;
	}


	modifier onlyOwner {

		require(msg.sender == owner,"Provide for owner.");
		_;
	}

	 modifier checkAdmin {
        
        require(administrators[msg.sender],"Provide for admin.");
        _;
    }

	function setTimeNow() public{
		TimeNow = block.timestamp;
	}

	function setlimitUntil(address _target, uint256 _until, uint256 _value, bool _frozen) onlyOwner public {

		require(_target != address(0x0));
			limitUntil[_target] = _until;
			limitation[_target] = _value;
			frozen[_target] = _frozen;

	}  


	function transferOwnership(address newOwner) onlyOwner public {

		owner = newOwner;
	}
	
	function _transfer(address _from, address _to, uint _value) internal {

		require(_to != address(0x0));
		require(balanceOf[_from] >= _value);
		require(balanceOf[_to] + _value > balanceOf[_to]);
		if ( frozen[_from] ) {
			// 1. 프로즌이 되어있다
			// 2. 날짜를 확인한다 . limituntil < timestamp 거래가능
			// 3. 잔고확인 
			if( limitUntil[_from] > 0){
				if(limitUntil[_from] > block.timestamp){ 
					require(balanceOf[_from] - _value >= limitation[_from], "Limit Enabled, Time Lock Enabled, Fail to transfer." );
				}
			}else{
					require(balanceOf[_from] - _value >= limitation[_from], "Limit Enabled,  Fail to transfer." );
			}
		}

		uint previousBalances = balanceOf[_from] + balanceOf[_to];
		balanceOf[_from] -= _value;
		balanceOf[_to] += _value;

		emit Transfer(_from, _to, _value);
		
		assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
	}

	function transfer(address _to, uint256 _value) public returns (bool success) {

		_transfer(msg.sender, _to, _value);

		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

		require(_value <= allowance[_from][msg.sender]);

		allowance[_from][msg.sender] -= _value;

		_transfer(_from, _to, _value);

		return true;
	}




    
    function setAdmin(address target, bool set) onlyOwner public {
        administrators[target] = set;
    }

	

	function approve(address _spender, uint256 _value) public returns (bool success) {

		allowance[msg.sender][_spender] = _value;

		emit Approval(msg.sender, _spender, _value);

		return true;
	}

	function burn(uint256 _value) onlyOwner public returns (bool success) {

		require(balanceOf[msg.sender] >= _value);

		balanceOf[msg.sender] -= _value;
		totalSupply -= _value;

		emit Burn(msg.sender, _value);
		return true;
	}

	function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {

		require(balanceOf[_from] >= _value);
		require(_value <= allowance[_from][msg.sender]);

		balanceOf[_from] -= _value;
		allowance[_from][msg.sender] -= _value;
		totalSupply -= _value;

		emit Burn(_from, _value);
		return true;
	}


	function multiLimit(address[] memory target, uint256[] memory limitBalance, bool freeze) onlyOwner public {
		for ( uint i=0; i<target.length; i++ ) {
			limitation[target[i]] = limitBalance[i];
			frozen[target[i]] = freeze;
		}
	}

	//from  NFT Creator <<<>>>to customer
	function TransferByNFT(
        address  _creatorAddress,
        address  _customerAddress,
        uint256 value
    ) checkAdmin external {
        require(_creatorAddress != address(0x0));
		require(balanceOf[_customerAddress] >= value);
		require(balanceOf[_creatorAddress] + value > balanceOf[_creatorAddress]);
		if (frozen[_customerAddress]) {
			if(limitUntil[_customerAddress] > block.timestamp){ 
				require(balanceOf[_customerAddress] - value > limitation[_customerAddress] );
			}
		}

		uint previousBalances = balanceOf[_customerAddress] + balanceOf[_creatorAddress];
		balanceOf[_customerAddress] -= value;
		balanceOf[_creatorAddress] += value;

        emit Transfer(_customerAddress, _creatorAddress, value);
		
		assert(balanceOf[_customerAddress] + balanceOf[_creatorAddress] == previousBalances);
    }

	function ApproveByNFT( address _sender,address _spender,uint256 _value) checkAdmin external returns(bool){
		require(balanceOf[_sender] >= _value,"ERC 20 : Error _sender input to over _value ");
		allowance[_sender][_spender] = _value;
		emit Approval(_sender, _spender, _value);
		return true;
	}

	function TransferFromByNFT(address _sender,address _from,address _to,uint256 _value) checkAdmin external returns(bool) {
		require(_value <= allowance[_to][_sender],"ERC 20 :  enter arg  more value than AmountAllowance input value ");
		allowance[_to][_sender] -= _value;
		_transfer( _to,_from, _value);
		return true;
	}

	function BalanceOfERC20Token(address _to) view   external returns(uint256){
		return balanceOf[_to];
	}

} 