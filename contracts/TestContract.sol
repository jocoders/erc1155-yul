// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Test, console } from 'forge-std/Test.sol';

contract TestContract {
  function test(bytes calldata value) public returns (bytes memory) {
    uint256 offset = 0;

    assembly {
      let pos := add(4, mul(offset, 0x20))
      if lt(calldatasize(), add(pos, 0x20)) {
        revert(0, 0)
      }
      let dataPointer := calldataload(pos)

      if lt(calldatasize(), add(dataPointer, 0x20)) {
        revert(0, 0)
      }

      let dataLength := calldataload(add(dataPointer, 4))

      let freeMemPointer := mload(0x40)

      mstore(freeMemPointer, dataLength)
      calldatacopy(add(freeMemPointer, 0x20), add(dataPointer, 0x24), dataLength)

      mstore(0x40, add(freeMemPointer, add(0x20, dataLength)))

      return(freeMemPointer, add(0x20, dataLength))
    }

    //console.log('ASSEMBLY_pos', pos);
    // console.log('ASSEMBLY_dataPointer', dataPointer);
    // console.log('ASSEMBLY_dataLength', dataLength);
  }

  function test2(bytes calldata value) public returns (uint256 dataPointer, uint256 dataLength) {
    uint256 offset = 0;
    uint256 pos;

    // console.log('1_value***');
    // console.logBytes(value);
    // console.log('1_value***');

    assembly {
      pos := add(4, mul(offset, 0x20))
      if lt(calldatasize(), add(pos, 0x20)) {
        revert(0, 0)
      }
      dataPointer := calldataload(pos)

      if lt(calldatasize(), add(dataPointer, 0x20)) {
        revert(0, 0)
      }

      dataLength := calldataload(dataPointer)
    }

    console.log('ASSEMBLY_pos', pos);
    // console.log('ASSEMBLY_dataPointer', dataPointer);
    // console.log('ASSEMBLY_dataLength', dataLength);
  }

  // function test3(uint256[] calldata value) public returns (uint256 dataPointer, uint256 dataLength) {
  //   uint256 offset = 0;

  //   assembly {
  //     pos := add(4, mul(offset, 0x20))
  //     if lt(calldatasize(), add(pos, 0x20)) {
  //       revert(0, 0)
  //     }

  //     let dataPointer := calldataload(pos)
  //     if lt(calldatasize(), add(dataPointer, 0x20)) {
  //       revert(0, 0)
  //     }
  //     dataLength := calldataload(dataPointer)
  //   }
  // }

  // 0xa5643bf2
  // 000000000000000000000000000000000000000000000000000000000000006
  // 00000000000000000000000000000000000000000000000000000000000000001
  // 00000000000000000000000000000000000000000000000000000000000000a0
  // 0000000000000000000000000000000000000000000000000000000000000004
  // 6461766500000000000000000000000000000000000000000000000000000000
  // 0000000000000000000000000000000000000000000000000000000000000003
  // 0000000000000000000000000000000000000000000000000000000000000001
  // 0000000000000000000000000000000000000000000000000000000000000002
  // 0000000000000000000000000000000000000000000000000000000000000003
}
