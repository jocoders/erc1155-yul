// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {YulDeployer} from "./lib/YulDeployer.sol";

interface DecodeLib {}

contract ERC1155YulTest is Test {
    YulDeployer yulDeployer = new YulDeployer();

    DecodeLib lib;

    address FROM = address(0x123);
    address TO = address(0x456);
    uint256 ID = 1;
    uint256 AMOUNT = 1;
    bytes DATA = "DATA";

    function setUp() public {
        lib = DecodeLib(yulDeployer.deployContract("DecodeLib"));
    }

    // function testDecodeToUint(uint256 value) public {
    //   bytes memory callDataBytes = abi.encodeWithSignature('decodeToUint(uint256)', value);
    //   (bool success, bytes memory returnData) = address(lib).call(callDataBytes);
    //   assertTrue(success);
    //   uint256 valueUint = abi.decode(returnData, (uint256));
    //   assertEq(valueUint, value, 'Returned value does not match');
    //   console.log('retInt', valueUint);
    // }

    // function testDecodeToAddress(address value) public {
    //   bytes memory callDataBytes = abi.encodeWithSignature('decodeToAddress(address)', value);
    //   (bool success, bytes memory returnData) = address(lib).call(callDataBytes);
    //   assertTrue(success);
    //   address valueAddr = abi.decode(returnData, (address));
    //   assertEq(valueAddr, value, 'Returned value does not match');
    //   console.log('valueAddr', valueAddr);
    // }

    //   function testDecodeToBytes(bytes memory value) public {
    //     console.log('IN');
    //     console.logBytes(value);
    //     console.log('IN');
    //     bytes memory callDataBytes = abi.encodeWithSignature('decodeToBytes(bytes)', value);
    //     (bool success, bytes memory returnData) = address(lib).call(callDataBytes);
    //     assertTrue(success);

    //     bytes memory valueBytes = abi.decode(returnData, (bytes));
    //     console.log('OUT');
    //     console.logBytes(valueBytes);
    //     console.log('OUT');
    //     // console.logBytes(dataPointer);
    //     // console.log('***1***');
    //     // console.log('***2***');
    //     // console.logBytes(value);
    //     // console.log('***2***');
    //     // assertEq(valueBytes, value, 'Returned value does not match');
    //   }

    function testDecodeArgs(bytes calldata cData) public {
        // onERC1155Received(address, address, uint256, uint256, bytes calldata)
        console.log("***IN***");
        console.logBytes(cData);
        console.log("***IN***");

        bytes memory callDataBytes = abi.encodeWithSignature(
            "decodeArgs(address,address,uint256,uint256,bytes)", address(0x123), address(0x456), 1, 1, cData
        );

        (bool success, bytes memory returnData) = address(lib).call(callDataBytes);
        assertTrue(success);
        uint256 val = abi.decode(returnData, (uint256));
        console.log("***VAL***", val);
    }
}
