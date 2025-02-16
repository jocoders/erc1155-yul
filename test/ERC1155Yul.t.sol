// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {YulDeployer} from "./lib/YulDeployer.sol";
import {ERC1155TokenReceiver} from "../contracts/ERC1155TokenReceiver.sol";

interface ERC1155 {}

contract Receiver is ERC1155TokenReceiver {
    address public from;
    address public to;
    uint256 public id;
    uint256 public amount;
    bytes public data;
    uint256[] public ids;
    uint256[] public amounts;

    //   fallback() external payable {
    //     console.log('***************!!!!!!!!!!!_FALLBACK_!!!!!!!!!!!!***************');
    //   }

    function onERC1155Received(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data)
        external
        override
        returns (bytes4)
    {
        console.log("***************!!!!!!!!!!!_onERC1155Received_!!!!!!!!!!!!***************");
        from = _from;
        to = _to;
        id = _id;
        amount = _amount;
        data = _data;

        console.log("_OUTPUT_BYTES_DATA_START_");
        console.logBytes(data);
        console.log("_OUTPUT_BYTES_DATA_END_");
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }

    function onERC1155BatchReceived(
        address _from,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _amounts,
        bytes calldata _data
    ) external override returns (bytes4) {
        console.log("***************!!!!!!!!!!!_onERC1155BatchReceived_!!!!!!!!!!!!***************");

        from = _from;
        to = _to;
        ids = _ids;
        amounts = _amounts;
        data = _data;

        console.log("_OUTPUT_BYTES_DATA_START_");
        console.logBytes(data);
        console.log("_OUTPUT_BYTES_DATA_END_");
        console.log("from", from);
        console.log("to", to);

        return bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"));
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

    function testApprovedForAll() public {
        _setApprovalForAll(Alice, true);
        _setApprovalForAll(Alice, false);
    }

    function testIsApprovedForAll() public {
        _setApprovalForAll(Alice, true);
        bytes memory callData = abi.encodeWithSignature("isApprovedForAll(address,address)", address(this), Alice);
        (bool success, bytes memory returnData) = erc1155().call(callData);
        bool isApproved = abi.decode(returnData, (bool));
        assertTrue(success, "Failed to check isApprovedForAll");
        assertEq(isApproved, true, "isApprovedForAll not set");
    }

    function testSupportsInterface() public {
        _testSupportsInterface(0x01ffc9a7);
        _testSupportsInterface(0xd9b67a26);
        _testSupportsInterface(0x0e89341c);

        bytes memory callData = abi.encodeWithSignature("supportsInterface(bytes4)", 0x0e84541c);
        (bool success, bytes memory returnData) = erc1155().call(callData);
        bool isSupported = abi.decode(returnData, (bool));

        assertTrue(success, "Failed to check supportsInterface");
        assertFalse(isSupported, "0x0e84541c not supported");
    }

    function testMint(bytes calldata cData) public {
        console.log("_INPUT_BYTES_DATA_START_");
        console.logBytes(cData);
        console.log("_INPUT_BYTES_DATA_END_");
        uint256 ID = 777;
        uint256 AMOUNT1 = 5;
        uint256 AMOUNT2 = 9;
        bool res1 = _mint(address(receiver), ID, AMOUNT1, cData);
        console.log("res1", res1);
        assertTrue(res1, "Failed to mint");

        bytes32 slot = keccak256(abi.encode(address(receiver), ID));
        bytes32 storedVal = vm.load(erc1155(), slot);
        assertEq(uint256(storedVal), AMOUNT1, "Amount not stored");

        bool res2 = _mint(address(receiver), ID, AMOUNT2, cData);
        assertTrue(res2, "Failed to mint");

        bytes32 slot2 = keccak256(abi.encode(address(receiver), ID));
        bytes32 storedVal2 = vm.load(erc1155(), slot2);
        assertEq(uint256(storedVal2), AMOUNT1 + AMOUNT2, "Amount not stored");
    }

    function testBurn(bytes calldata cData) public {
        uint256 ID = 333;
        uint256 AMOUNT_MINT = 292;
        bool res1 = _mint(address(receiver), ID, AMOUNT_MINT, cData);
        assertTrue(res1, "Failed to mint");

        uint256 storedVal = _getStoredValue(address(receiver), ID);
        assertEq(storedVal, AMOUNT_MINT, "Amount not stored");

        uint256 AMOUNT_BURN = 100;
        bool success = _burn(address(receiver), ID, AMOUNT_BURN);
        assertTrue(success, "Failed to burn");

        uint256 storedVal2 = _getStoredValue(address(receiver), ID);
        assertEq(storedVal2, AMOUNT_MINT - AMOUNT_BURN, "Amount not burned");

        uint256 AMOUNT_BURN2 = 39;
        bool success2 = _burn(address(receiver), ID, AMOUNT_BURN2);
        assertTrue(success2, "Failed to burn");

        uint256 storedVal3 = _getStoredValue(address(receiver), ID);
        assertEq(storedVal3, AMOUNT_MINT - AMOUNT_BURN - AMOUNT_BURN2, "Amount not burned");
    }

    function testSafeTransferFromFailed(bytes calldata cData) public {
        address TO = address(0x456);
        uint256 ID = 45;
        uint256 AMOUNT = 9;

        vm.expectRevert();
        _transfer(Alice, TO, ID, AMOUNT, cData);
    }

    function testSafeTransferFromUnderflowRevert(bytes calldata cData) public {
        uint256 ID = 777;
        uint256 AMOUNT1 = 59;
        uint256 AMOUNT_SENT = 19;
        bool res1 = _mint(address(receiver), ID, AMOUNT1, cData);
        assertTrue(res1, "Failed to mint");

        uint256 storedVal = _getStoredValue(address(receiver), ID);
        assertEq(storedVal, AMOUNT1, "Amount not stored");

        vm.expectRevert();
        _transfer(address(this), address(receiver2), ID, AMOUNT_SENT, cData);
    }

    function testBalanceOfBatch(bytes calldata cData1) public {
        uint256 ID1 = 777;
        uint256 AMOUNT1 = 59;
        bool res1 = _mint(Alice, ID1, AMOUNT1, cData1);
        assertTrue(res1, "Failed to mint Alice");
        accounts.push(Alice);
        ids.push(ID1);

        uint256 ID2 = 808;
        uint256 AMOUNT2 = 48;
        bool res2 = _mint(Bob, ID2, AMOUNT2, cData1);
        assertTrue(res2, "Failed to mint Bob");
        accounts.push(Bob);
        ids.push(ID2);

        uint256 ID3 = 3456;
        uint256 AMOUNT3 = 4880;
        bool res3 = _mint(Jo, ID3, AMOUNT3, cData1);
        assertTrue(res3, "Failed to mint Jo");
        accounts.push(Jo);
        ids.push(ID3);

        bytes memory callDataBytes = abi.encodeWithSignature("balanceOfBatch(address[],uint256[])", accounts, ids);
        (bool success, bytes memory returnData) = erc1155().call(callDataBytes);
        assertTrue(success);
        uint256[] memory balances = abi.decode(returnData, (uint256[]));
        assertEq(balances[0], AMOUNT1, "Alice balance not correct");
        assertEq(balances[1], AMOUNT2, "Bob balance not correct");
        assertEq(balances[2], AMOUNT3, "Jo balance not correct");
    }

    function testSafeTransferFrom(bytes calldata cData1, bytes calldata cData2) public {
        console.log("_INPUT_BYTES_DATA_START_");
        console.logBytes(cData2);
        console.log("_INPUT_BYTES_DATA_END_");

        uint256 ID = 777;
        uint256 AMOUNT1 = 59;
        uint256 AMOUNT_SENT = 19;
        bool res1 = _mint(address(receiver), ID, AMOUNT1, cData1);
        assertTrue(res1, "Failed to mint");

        uint256 storedVal = _getStoredValue(address(receiver), ID);
        assertEq(storedVal, AMOUNT1, "Amount not stored");

        vm.prank(address(receiver));
        bool success = _transfer(address(receiver), address(receiver2), ID, AMOUNT_SENT, cData2);
        assertEq(success, true, "testSafeTransferFrom should be success");

        uint256 storedVal2 = _getStoredValue(address(receiver), ID);
        assertEq(storedVal2, AMOUNT1 - AMOUNT_SENT, "Amount not stored");

        uint256 storedVal3 = _getStoredValue(address(receiver2), ID);
        assertEq(storedVal3, AMOUNT_SENT, "Amount not stored");
    }

    function testBatchMint(bytes calldata cData) public {
        _batchMint(cData, address(receiver));
    }

    function testBatchMintToEoa(bytes calldata cData) public {
        _batchMint(cData, Alice);
    }

    function testBurnFromEoa(bytes calldata cData) public {
        _batchMint(cData, Alice);

        uint256[] memory _ids;
        uint256[] memory _amounts;

        _ids = new uint256[](3);
        _amounts = new uint256[](3);

        _ids[0] = 77;
        _ids[1] = 88;
        _ids[2] = 99;
        // _ids[3] = 111;
        // _ids[4] = 123;

        _amounts[0] = 777;
        _amounts[1] = 888;
        _amounts[2] = 999;

        for (uint256 i = 0; i < _ids.length; i++) {
            _burn(Alice, _ids[i], _amounts[i]);
        }

        _checkBatchStoredValues(Alice, _ids, _amounts, true);
    }

    function testSafeBatchTransferFrom(bytes calldata cData) public {
        _logAddress();
        (uint256[] memory _ids, uint256[] memory _amounts) = _batchMint(cData, address(receiver));

        vm.prank(address(receiver));
        bytes memory callData = abi.encodeWithSignature(
            "safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)",
            address(receiver),
            address(receiver2),
            _ids,
            _amounts,
            cData
        );
        (bool success,) = erc1155().call(callData);
        assertTrue(success, "Failed to safeBatchTransferFrom");
        _checkBatchStoredValues(address(receiver), _ids, _amounts, true);
        _checkBatchStoredValues(address(receiver2), _ids, _amounts, false);
    }

    function testBatchBurnToZero(bytes calldata cData) public {
        (uint256[] memory _ids, uint256[] memory _amounts) = _batchMint(cData, address(receiver));

        bytes memory callData =
            abi.encodeWithSignature("batchBurn(address,uint256[],uint256[])", address(receiver), _ids, _amounts);
        (bool success,) = erc1155().call(callData);
        assertTrue(success, "Failed to batch burn");

        _checkBatchStoredValues(address(receiver), _ids, _amounts, true);
    }

    function _setApprovalForAll(address operator, bool approved) public {
        bytes memory callData = abi.encodeWithSignature("setApprovalForAll(address,bool)", operator, approved);
        vm.expectEmit(true, true, true, true);
        emit ApprovalForAll(address(this), operator, approved);
        (bool success,) = erc1155().call(callData);
        assertTrue(success, "Failed to set approval for all");

        bytes32 slot = keccak256(abi.encode(address(this), operator));
        bytes32 storedVal = vm.load(erc1155(), slot);

        assertEq(uint256(storedVal), approved ? 1 : 0, "Approval for all not set");
    }

    function _batchMint(bytes memory cData, address to)
        public
        returns (uint256[] memory _ids, uint256[] memory _amounts)
    {
        console.log("***************!!!!!!!!!!!_DATA_!!!!!!!!!!!!***************");
        console.logBytes(cData);
        console.log("***************!!!!!!!!!!!_DATA_!!!!!!!!!!!!***************");

        _logAddress();

        _ids = new uint256[](3);
        _amounts = new uint256[](3);

        _ids[0] = 77;
        _ids[1] = 88;
        _ids[2] = 99;
        // _ids[3] = 111;
        // _ids[4] = 123;

        _amounts[0] = 777;
        _amounts[1] = 888;
        _amounts[2] = 999;
        // _amounts[3] = 1111;
        // _amounts[4] = 1234;

        bytes memory callData =
            abi.encodeWithSignature("batchMint(address,uint256[],uint256[],bytes)", to, _ids, _amounts, cData);
        (bool success,) = erc1155().call(callData);
        console.log("success", success);
        assertTrue(success, "Failed to batch mint");
        _checkBatchStoredValues(to, _ids, _amounts, false);
    }

    function _checkBatchStoredValues(address to, uint256[] memory _ids, uint256[] memory _amounts, bool _isZero)
        private
    {
        for (uint256 i = 0; i < _ids.length; i++) {
            uint256 storedVal = _getStoredValue(to, _ids[i]);
            assertEq(storedVal, _isZero ? 0 : _amounts[i], "Amount not stored");
        }
    }

    function _testSupportsInterface(bytes4 selector) public {
        bytes memory callData = abi.encodeWithSignature("supportsInterface(bytes4)", selector);
        (bool success, bytes memory returnData) = erc1155().call(callData);
        bool isSupported = abi.decode(returnData, (bool));

        assertTrue(success, "Failed to check supportsInterface");
        assertTrue(isSupported, "ERC1155 not supported");
    }

    function _mint(address to, uint256 id, uint256 amount, bytes calldata cData) private returns (bool success) {
        bytes memory callDataBytes =
            abi.encodeWithSignature("mint(address,uint256,uint256,bytes)", to, id, amount, cData);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(this), address(0), to, id, amount);
        (success,) = erc1155().call(callDataBytes);
    }

    function _burn(address from, uint256 id, uint256 amount) private returns (bool success) {
        bytes memory callData = abi.encodeWithSignature("burn(address,uint256,uint256)", from, id, amount);
        vm.expectEmit(true, true, true, true);
        emit TransferSingle(address(this), from, address(0), id, amount);
        (success,) = erc1155().call(callData);
    }

    function _getStoredValue(address from, uint256 id) private returns (uint256) {
        bytes32 slot = keccak256(abi.encode(from, id));
        bytes32 storedVal = vm.load(erc1155(), slot);
        return uint256(storedVal);
    }

    function _transfer(address from, address to, uint256 id, uint256 amount, bytes calldata data)
        private
        returns (bool success)
    {
        bytes memory callDataBytes = abi.encodeWithSignature(
            "safeTransferFrom(address,address,uint256,uint256,bytes)", from, to, id, amount, data
        );
        (success,) = erc1155().call(callDataBytes);
    }

    function _logAddress() private view {
        console.log("***************!!!!!!!!!!!_ADDRESS_!!!!!!!!!!!!***************");
        console.log(address(receiver));
        console.log(address(receiver2));
        console.log(address(this));
        console.log("***************!!!!!!!!!!!_ADDRESS_!!!!!!!!!!!!***************");
    }
}
