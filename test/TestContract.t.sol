// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {TestContract} from "../contracts/TestContract.sol";

contract TestContractTest is Test {
    TestContract testContract;

    function setUp() public {
        testContract = new TestContract();
    }

    //   function testBytesX(bytes calldata value) public {
    //     console.log('START!!!');
    //     console.logBytes(value);
    //     console.log('END!!!');
    //     bytes memory callDataBytes = abi.encodeWithSignature('test(bytes)', value);
    //     (bool success, bytes memory returnData) = address(testContract).call(callDataBytes);
    //     assertTrue(success);

    //     uint256 dataLength = abi.decode(returnData, (uint256));
    //     // console.log('dataPointer', dataPointer);
    //     console.log('dataLength', dataLength);
    //   }

    //   function testBytesY(bytes calldata value) public {
    //     console.log('1_START!!!');
    //     console.logBytes(value);
    //     console.log('1_END!!!');
    //     bytes memory callDataBytes = abi.encodeWithSignature('test(bytes)', value);
    //     (bool success, bytes memory returnData) = address(testContract).call(callDataBytes);
    //     assertTrue(success);

    //     bytes memory data = abi.decode(returnData, (bytes));
    //     console.log('2_START!!!');
    //     console.logBytes(data);
    //     console.log('2_END!!!');
    //   }

    //   function testBytesY(bytes calldata value) public {
    //     console.log('1_START!!!');
    //     console.logBytes(value);
    //     console.log('1_END!!!');
    //     bytes memory callDataBytes = abi.encodeWithSignature('test2(bytes)', value);
    //     (bool success, bytes memory returnData) = address(testContract).call(callDataBytes);
    //     assertTrue(success);

    //     (uint256 dataPointer, uint256 dataLength) = abi.decode(returnData, (uint256, uint256));
    //     console.log('dataPointer', dataPointer);
    //     console.log('dataLength', dataLength);
    //   }

    // function testBytesY(uint256[] calldata value) public {
    //   bytes memory callDataBytes = abi.encodeWithSignature('test3(uint256[])', value);
    //   (bool success, bytes memory returnData) = address(testContract).call(callDataBytes);
    //   assertTrue(success);

    //   (uint256 dataPointer, uint256 dataLength) = abi.decode(returnData, (uint256, uint256));
    //   console.log('dataPointer', dataPointer);
    //   console.log('dataLength', dataLength);
    // }
}
