// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {YulDeployer} from "./lib/YulDeployer.sol";

interface ERC1155 {}

contract Receiver {
    bytes4 public constant ERC1155_RECEIVED =
        bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    address public _from;
    address public _to;
    uint256 public _id;
    uint256 public _amount;
    bytes public _data;

    function onERC1155Received(address from, address to, uint256 id, uint256 amount, bytes calldata data)
        external
        returns (bytes4)
    {
        // onERC1155Received(address,address,uint256,uint256,bytes)
        console.log("***************!!!!!!!!!!!_onERC1155Received_!!!!!!!!!!!!***************");
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
    Receiver receiver = new Receiver();
    Receiver receiver2 = new Receiver();
    ERC1155 yulContract;

    address Alice = 0xAdFb8D27671F14f297eE94135e266aAFf8752e35;
    address Bob = 0xAD607ad250e1463D4Da5cCed8E2291a67a7B3740;
    address Jo = 0x0Ec907EFFc88F0046939F52c7a91B1f6713Feb7f;

    address[] accounts;
    uint256[] ids;

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event TransferSingle(
        address indexed operator, address indexed from, address indexed to, uint256 id, uint256 amount
    );

    function setUp() public {
        yulContract = ERC1155(yulDeployer.deployContract("ERC1155"));
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
    //   uint256 ID = 777;
    //   uint256 AMOUNT1 = 5;
    //   uint256 AMOUNT2 = 9;
    //   bool res1 = mint(address(receiver), ID, AMOUNT1, cData);
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

    function mint(address to, uint256 id, uint256 amount, bytes calldata cData) public returns (bool success) {
        bytes memory callDataBytes =
            abi.encodeWithSignature("mint(address,uint256,uint256,bytes)", to, id, amount, cData);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(this), address(0), to, id, amount);
        (success,) = erc1155().call(callDataBytes);
    }

    // function burn(address from, uint256 id, uint256 amount) public returns (bool success) {
    //   bytes memory callData = abi.encodeWithSignature('burn(address,uint256,uint256)', from, id, amount);
    //   vm.expectEmit(true, true, true, true);
    //   emit TransferSingle(address(this), from, address(0), id, amount);
    //   (success, ) = erc1155().call(callData);
    // }

    // function getStoredValue(address from, uint256 id) public returns (uint256) {
    //   bytes32 slot = keccak256(abi.encode(from, id));
    //   bytes32 storedVal = vm.load(erc1155(), slot);
    //   return uint256(storedVal);
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

    // function testSafeTransferFromFailed(bytes calldata cData) public {
    //   address TO = address(0x456);
    //   uint256 ID = 45;
    //   uint256 AMOUNT = 9;

    //   vm.expectRevert();
    //   bool success = transfer(Alice, TO, ID, AMOUNT, cData);
    //   assertTrue(!success, 'Transfer should fail');
    // }

    function testSafeTransferFrom(bytes calldata cData) public {
        uint256 ID = 777;
        uint256 AMOUNT1 = 59;
        uint256 AMOUNT_SENT = 19;
        bool res1 = mint(address(receiver), ID, AMOUNT1, cData);
        assertTrue(res1, "Failed to mint");

        bytes32 slot = keccak256(abi.encode(address(receiver), ID));
        bytes32 storedVal = vm.load(erc1155(), slot);
        assertEq(uint256(storedVal), AMOUNT1, "Amount not stored");

        bool success = transfer(address(this), address(receiver2), ID, AMOUNT_SENT, cData);
        assertTrue(success, "Transfer should fail");
    }

    function transfer(address from, address to, uint256 id, uint256 amount, bytes calldata data)
        private
        returns (bool success)
    {
        bytes memory callDataBytes = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,uint256,bytes)", from, to, id, amount, data
        );
        (success,) = erc1155().call(callDataBytes);
    }
}
