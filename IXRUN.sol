 /*Submitted for verification at Etherscan.io on 2019-05-13*/
pragma solidity ^0.8.11;

interface IXRUN{
      function TransferByNFT(
        address  _creatorAddress,
        address  _customerAddress,
        uint256 value) external ;

      function ApproveByNFT(
        address _sender,
        address _spender,
        uint256 _value
      ) external returns(bool);

      function TransferFromByNFT(
        address _sender,
        address _from,
        address _to,
        uint256 _value
      ) external returns(bool);

      function BalanceOfERC20Token(address _to) 
      external view returns (uint256);
}