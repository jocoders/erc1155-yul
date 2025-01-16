// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Test, console } from 'forge-std/Test.sol';
import { YulDeployer } from './lib/YulDeployer.sol';

interface ERC1155 {}

contract Receiever {
  bytes4 public constant ERC1155_RECEIVED =
    bytes4(keccak256('onERC1155Received(address,address,uint256,uint256,bytes)'));
  address public _from;
  address public _to;
  uint256 public _id;
  uint256 public _amount;
  bytes public _data;

  function onERC1155Received(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
  ) external returns (bytes4) {
    // onERC1155Received(address,address,uint256,uint256,bytes)
    console.log('***************!!!!!!!!!!!_onERC1155Received_!!!!!!!!!!!!***************');
    _from = from;
    _to = to;
    _id = id;
    _amount = amount;
    _data = data;

    // console.log('2_FROM', _from);
    // console.log('2_TO', _to);
    // console.log('2_ID', _id);
    // console.log('2_AMOUNT', _amount);
    // console.log('2_DATA_START');
    // console.logBytes(_data);
    // console.log('2_DATA_END');
    return ERC1155_RECEIVED;
  }
}

contract ERC1155YulTest is Test {
  YulDeployer yulDeployer = new YulDeployer();
  Receiever receiever = new Receiever();
  ERC1155 yulContract;

  address Alice = 0xAdFb8D27671F14f297eE94135e266aAFf8752e35;
  address Bob = 0xAD607ad250e1463D4Da5cCed8E2291a67a7B3740;
  address Jo = 0x0Ec907EFFc88F0046939F52c7a91B1f6713Feb7f;

  address[] accounts;
  uint256[] ids;

  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

  function setUp() public {
    yulContract = ERC1155(yulDeployer.deployContract('ERC1155'));
    receiever = new Receiever();
  }

  function erc1155() public view returns (address) {
    return address(yulContract);
  }

  // function testSupportsInterface() public {
  //   bytes memory callData = abi.encodeWithSignature('supportsInterface(bytes4)', 0x01ffc9a7);
  //   (bool success, ) = erc1155().call(callData);
  //   assertTrue(success, 'Failed to check supportsInterface');

  //   bytes memory callData1 = abi.encodeWithSignature('supportsInterface(bytes4)', 0xd9b67a26);
  //   (bool success1, ) = erc1155().call(callData1);
  //   assertTrue(success1, 'Failed to check supportsInterface');

  //   bytes memory callData2 = abi.encodeWithSignature('supportsInterface(bytes4)', 0x0e89341c);
  //   (bool success2, ) = erc1155().call(callData2);
  //   assertTrue(success2, 'Failed to check supportsInterface');
  // }

  // function testApprovedForAll() public {
  //   bytes memory callData = abi.encodeWithSignature('setApprovalForAll(address,bool)', Alice, true);
  //   vm.expectEmit(true, true, true, true);
  //   emit ApprovalForAll(address(this), Alice, true);
  //   (bool success, ) = erc1155().call(callData);
  //   assertTrue(success, 'Failed to set approval for all');

  //   bytes32 slot = keccak256(abi.encode(address(this), Alice));
  //   bytes32 storedVal = vm.load(erc1155(), slot);

  //   assertEq(uint256(storedVal), 1, 'Approval for all not set');
  // }

  function testMint(bytes calldata cData) public {
    console.log('***IN***');
    console.logBytes(cData);
    console.log('***IN***');
    uint256 ID = 777;
    bytes memory callDataBytes = abi.encodeWithSignature(
      'mint(address,uint256,uint256,bytes)',
      address(receiever),
      ID,
      5,
      cData
    );
    (bool success, ) = erc1155().call(callDataBytes);
    assertTrue(success, 'Failed to mint');

    console.log('1_FROM', receiever._from());
    console.log('1_TO', receiever._to());
    console.log('1_ID', receiever._id());
    console.log('1_AMOUNT', receiever._amount());
    console.log('1_DATA_START');
    console.logBytes(receiever._data());
    console.log('1_DATA_END');
  }

  // function testCheckDecodeToUint(uint256 value) public {
  //   bytes memory callDataBytes = abi.encodeWithSignature('checkDecodeToUint(uint256)', value);
  //   (bool success, bytes memory returnData) = erc1155().call(callDataBytes);
  //   assertTrue(success);
  //   uint256 retValue = abi.decode(returnData, (uint256));
  //   assertEq(retValue, value, 'Returned value does not match');
  // }

  // function testCheckDecodeToAddress(address value) public {
  //   bytes memory callDataBytes = abi.encodeWithSignature('checkDecodeToAddress(address)', value);
  //   (bool success, bytes memory returnData) = erc1155().call(callDataBytes);
  //   assertTrue(success);
  //   address retValue = abi.decode(returnData, (address));
  //   assertEq(retValue, value, 'Returned value does not match');
  // }

  // function testBalanceOfBatch() public {
  //   accounts.push(Alice);
  //   accounts.push(Bob);
  //   accounts.push(Jo);

  //   ids.push(8);
  //   ids.push(9);
  //   ids.push(10);

  //   bytes memory callDataBytes = abi.encodeWithSignature('balanceOfBatch(address[],uint256[])', accounts, ids);
  //   (bool success, ) = erc1155().call(callDataBytes);
  //   //assertTrue(success);
  // }

  // function testSafeTransferFrom() public {
  //   address FROM = address(0x123);
  //   address TO = address(0x456);
  //   uint256 ID = 1;
  //   uint256 AMOUNT = 1;
  //   bytes memory callDataBytes = abi.encodeWithSignature(
  //     'safeTransferFrom(address,address,uint256,uint256,bytes)',
  //     FROM,
  //     TO,
  //     ID,
  //     AMOUNT,
  //     'data'
  //   );

  //   (bool success, bytes memory returnData) = erc1155().call(callDataBytes);
  //   assertTrue(success);

  //   // Декодирование возвращаемых данных
  //   (address retFrom, address retTo, uint256 retId, uint256 retAmount, bytes memory retData) = abi.decode(
  //     returnData,
  //     (address, address, uint256, uint256, bytes)
  //   );
  // }
}
