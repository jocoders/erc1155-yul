// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Test, console } from 'forge-std/Test.sol';
import { YulDeployer } from './lib/YulDeployer.sol';
import { ERC1155TokenReceiver } from '../contracts/ERC1155TokenReceiver.sol';

interface ERC1155 {}

contract Receiver is ERC1155TokenReceiver {
  address public from;
  address public to;
  uint256 public id;
  uint256 public amount;
  bytes public data;
  uint256[] public ids;
  uint256[] public amounts;

  function onERC1155Received(
    address _from,
    address _to,
    uint256 _id,
    uint256 _amount,
    bytes calldata _data
  ) external override returns (bytes4) {
    console.log('***************!!!!!!!!!!!_onERC1155Received_!!!!!!!!!!!!***************');
    from = _from;
    to = _to;
    id = _id;
    amount = _amount;
    data = _data;

    console.log('2_FROM', from);
    console.log('2_TO', to);
    console.log('2_ID', id);
    console.log('2_AMOUNT', amount);
    console.log('2_DATA_START');
    console.logBytes(data);
    console.log('2_DATA_END');
    return bytes4(keccak256('onERC1155Received(address,address,uint256,uint256,bytes)'));
  }

  function onERC1155BatchReceived(
    address _from,
    address _to,
    uint256[] calldata _ids,
    uint256[] calldata _amounts,
    bytes calldata _data
  ) external override returns (bytes4) {
    console.log('***************!!!!!!!!!!!_onERC1155BatchReceived_!!!!!!!!!!!!***************');
    from = _from;
    to = _to;
    ids = _ids;
    amounts = _amounts;
    data = _data;
    return bytes4(keccak256('onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)'));
  }
}

contract ERC1155YulTest is Test {
  YulDeployer yulDeployer = new YulDeployer();
  Receiver receiver = new Receiver();
  Receiver receiver2 = new Receiver();
  ERC1155 yulContract;

  address Alice = 0xAdFb8D27671F14f297eE94135e266aAFf8752e35;
  address Bob = 0xAD607ad250e1463D4Da5cCed8E2291a67a7B3740;
  address Jo = 0x0Ec907EFFc88F0046939F52c7a91B1f6713Feb7f;

  address[] accounts;
  uint256[] ids;

  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
  event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 amount);

  function setUp() public {
    yulContract = ERC1155(yulDeployer.deployContract('ERC1155'));
    receiver = new Receiver();
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

  // function testMint(bytes calldata cData) public {
  //   console.log('_CDATA_');
  //   console.logBytes(cData);
  //   console.log('_CDATA_');
  //   uint256 ID = 777;
  //   uint256 AMOUNT1 = 5;
  //   uint256 AMOUNT2 = 9;
  //   bool res1 = mint(address(receiver), ID, AMOUNT1, cData);
  //   console.log('res1', res1);
  //   assertTrue(res1, 'Failed to mint');

  //   bytes32 slot = keccak256(abi.encode(address(receiver), ID));
  //   bytes32 storedVal = vm.load(erc1155(), slot);
  //   assertEq(uint256(storedVal), AMOUNT1, 'Amount not stored');

  //   bool res2 = mint(address(receiver), ID, AMOUNT2, cData);
  //   assertTrue(res2, 'Failed to mint');

  //   bytes32 slot2 = keccak256(abi.encode(address(receiver), ID));
  //   bytes32 storedVal2 = vm.load(erc1155(), slot2);
  //   assertEq(uint256(storedVal2), AMOUNT1 + AMOUNT2, 'Amount not stored');
  // }

  // function testBurn(bytes calldata cData) public {
  //   uint256 ID = 333;
  //   uint256 AMOUNT_MINT = 292;
  //   bool res1 = mint(address(receiver), ID, AMOUNT_MINT, cData);
  //   assertTrue(res1, 'Failed to mint');

  //   uint256 storedVal = getStoredValue(address(receiver), ID);
  //   assertEq(storedVal, AMOUNT_MINT, 'Amount not stored');

  //   uint256 AMOUNT_BURN = 100;
  //   bool success = burn(address(receiver), ID, AMOUNT_BURN);
  //   assertTrue(success, 'Failed to burn');

  //   uint256 storedVal2 = getStoredValue(address(receiver), ID);
  //   assertEq(storedVal2, AMOUNT_MINT - AMOUNT_BURN, 'Amount not burned');

  //   uint256 AMOUNT_BURN2 = 39;
  //   bool success2 = burn(address(receiver), ID, AMOUNT_BURN2);
  //   assertTrue(success2, 'Failed to burn');

  //   uint256 storedVal3 = getStoredValue(address(receiver), ID);
  //   assertEq(storedVal3, AMOUNT_MINT - AMOUNT_BURN - AMOUNT_BURN2, 'Amount not burned');
  // }

  // function testSafeTransferFromFailed(bytes calldata cData) public {
  //   address TO = address(0x456);
  //   uint256 ID = 45;
  //   uint256 AMOUNT = 9;

  //   vm.expectRevert();
  //   transfer(Alice, TO, ID, AMOUNT, cData);
  // }

  // function testSafeTransferFromUnderflowRevert(bytes calldata cData) public {
  //   uint256 ID = 777;
  //   uint256 AMOUNT1 = 59;
  //   uint256 AMOUNT_SENT = 19;
  //   bool res1 = mint(address(receiver), ID, AMOUNT1, cData);
  //   assertTrue(res1, 'Failed to mint');

  //   uint256 storedVal = getStoredValue(address(receiver), ID);
  //   assertEq(storedVal, AMOUNT1, 'Amount not stored');

  //   vm.expectRevert();
  //   transfer(address(this), address(receiver2), ID, AMOUNT_SENT, cData);
  // }

  // function testBalanceOfBatch(bytes calldata cData1) public {
  //   console.log('***************!!!!!!!!!!!_ADDRESS_!!!!!!!!!!!!***************');
  //   console.log(address(receiver));
  //   console.log(address(receiver2));
  //   console.log(address(this));
  //   console.log('***************!!!!!!!!!!!_ADDRESS_!!!!!!!!!!!!***************');

  //   uint256 ID1 = 777;
  //   uint256 AMOUNT1 = 59;
  //   bool res1 = mint(Alice, ID1, AMOUNT1, cData1);
  //   assertTrue(res1, 'Failed to mint Alice');
  //   accounts.push(Alice);
  //   ids.push(ID1);

  //   uint256 ID2 = 808;
  //   uint256 AMOUNT2 = 48;
  //   bool res2 = mint(Bob, ID2, AMOUNT2, cData1);
  //   assertTrue(res2, 'Failed to mint Bob');
  //   accounts.push(Bob);
  //   ids.push(ID2);

  //   uint256 ID3 = 3456;
  //   uint256 AMOUNT3 = 4880;
  //   bool res3 = mint(Jo, ID3, AMOUNT3, cData1);
  //   assertTrue(res3, 'Failed to mint Jo');
  //   accounts.push(Jo);
  //   ids.push(ID3);

  //   bytes memory callDataBytes = abi.encodeWithSignature('balanceOfBatch(address[],uint256[])', accounts, ids);
  //   (bool success, bytes memory returnData) = erc1155().call(callDataBytes);
  //   assertTrue(success);
  //   uint256[] memory balances = abi.decode(returnData, (uint256[]));
  //   assertEq(balances[0], AMOUNT1, 'Alice balance not correct');
  //   assertEq(balances[1], AMOUNT2, 'Bob balance not correct');
  //   assertEq(balances[2], AMOUNT3, 'Jo balance not correct');
  // }

  // function testSafeTransferFrom(bytes calldata cData1, bytes calldata cData2) public {

  //   console.log('_CDATA_');
  //   console.logBytes(cData2);
  //   console.log('_CDATA_');

  //   uint256 ID = 777;
  //   uint256 AMOUNT1 = 59;
  //   uint256 AMOUNT_SENT = 19;
  //   bool res1 = mint(address(receiver), ID, AMOUNT1, cData1);
  //   assertTrue(res1, 'Failed to mint');

  //   uint256 storedVal = getStoredValue(address(receiver), ID);
  //   assertEq(storedVal, AMOUNT1, 'Amount not stored');

  //   vm.prank(address(receiver));
  //   bool success = transfer(address(receiver), address(receiver2), ID, AMOUNT_SENT, cData2);
  //   console.log('success', success);
  //   assertEq(success, true, 'testSafeTransferFrom should be success');

  //   uint256 storedVal2 = getStoredValue(address(receiver), ID);
  //   assertEq(storedVal2, AMOUNT1 - AMOUNT_SENT, 'Amount not stored');

  //   uint256 storedVal3 = getStoredValue(address(receiver2), ID);
  //   assertEq(storedVal3, AMOUNT_SENT, 'Amount not stored');
  // }

  //   function testSafeBatchTransferFrom(bytes calldata cData) public {
  //     uint256[] memory amounts = new uint256[](2);
  //     amounts[0] = 17;
  //     amounts[1] = 18;

  //     uint256[] memory batchIds = new uint256[](2);
  //     batchIds[0] = 404;
  //     batchIds[1] = 505;

  //     bytes memory callData = abi.encodeWithSignature(
  //       'safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)',
  //       address(this),
  //       Bob,
  //       batchIds,
  //       amounts,
  //       cData
  //     );
  //     (bool success, ) = erc1155().call(callData);
  //     // assertTrue(success, 'Failed to safeBatchTransferFrom');
  //   }

  function testBatchMint(bytes calldata cData) public {
    uint256[] memory ids = new uint256[](3);
    ids[0] = 77;
    ids[1] = 88;
    ids[2] = 99;

    uint256[] memory amounts = new uint256[](3);
    amounts[0] = 777;
    amounts[1] = 888;
    amounts[2] = 999;

    bytes memory callData = abi.encodeWithSignature(
      'batchMint(address,uint256[],uint256[],bytes)',
      address(receiver),
      ids,
      amounts,
      cData
    );
    (bool success, ) = erc1155().call(callData);
    assertTrue(success, 'Failed to batch mint');

    bytes32 slot = keccak256(abi.encode(address(receiver), 77));
    bytes32 storedVal = vm.load(erc1155(), slot);
    console.log('storedVal', uint256(storedVal));
    assertEq(uint256(storedVal), 777, 'Amount not stored');

    bytes32 slot1 = keccak256(abi.encode(address(receiver), 88));
    bytes32 storedVal1 = vm.load(erc1155(), slot1);
    console.log('storedVal1', uint256(storedVal1));
    assertEq(uint256(storedVal1), 888, 'Amount not stored');

    bytes32 slot2 = keccak256(abi.encode(address(receiver), 99));
    bytes32 storedVal2 = vm.load(erc1155(), slot2);
    console.log('storedVal2', uint256(storedVal2));
    assertEq(uint256(storedVal2), 999, 'Amount not stored');
  }

  function mint(address to, uint256 id, uint256 amount, bytes calldata cData) private returns (bool success) {
    bytes memory callDataBytes = abi.encodeWithSignature('mint(address,uint256,uint256,bytes)', to, id, amount, cData);
    //vm.expectEmit(true, true, true, true);
    emit TransferSingle(address(this), address(0), to, id, amount);
    (success, ) = erc1155().call(callDataBytes);
  }

  function burn(address from, uint256 id, uint256 amount) private returns (bool success) {
    bytes memory callData = abi.encodeWithSignature('burn(address,uint256,uint256)', from, id, amount);
    vm.expectEmit(true, true, true, true);
    emit TransferSingle(address(this), from, address(0), id, amount);
    (success, ) = erc1155().call(callData);
  }

  function getStoredValue(address from, uint256 id) private returns (uint256) {
    bytes32 slot = keccak256(abi.encode(from, id));
    bytes32 storedVal = vm.load(erc1155(), slot);
    return uint256(storedVal);
  }

  function transfer(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
  ) private returns (bool success) {
    bytes memory callDataBytes = abi.encodeWithSignature(
      'safeTransferFrom(address,address,uint256,uint256,bytes)',
      from,
      to,
      id,
      amount,
      data
    );
    (success, ) = erc1155().call(callDataBytes);
  }

  function logAddress() private {
    console.log('***************!!!!!!!!!!!_ADDRESS_!!!!!!!!!!!!***************');
    console.log(address(receiver));
    console.log(address(receiver2));
    console.log(address(this));
    console.log('***************!!!!!!!!!!!_ADDRESS_!!!!!!!!!!!!***************');
  }
}
