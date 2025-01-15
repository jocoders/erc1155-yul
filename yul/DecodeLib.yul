object "DecodeLib" {
  code {
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime" {
    code {
      // Protection against sending Ether
      require(iszero(callvalue()))

      // Dispatcher
      switch selector()
      case 0xceebd8b1 /* "decodeToUint(uint256)" */ {
        let value := decodeToUint(0)
        let freeMemPointer := mload(0x40)
        mstore(freeMemPointer, value)

        return(freeMemPointer, 0x20)
      }
      case 0xec25dad9 /* "decodeToAddress(address)" */ {
        let value := decodeToAddress(0)
        let freeMemPointer := mload(0x40)
        mstore(freeMemPointer, value)

        return(freeMemPointer, 0x20)
      }
      case 0x89679e8a /* decodeArgs(address,address,uint256,uint256,bytes) */ {
        let operator := decodeToAddress(0)
        let from := decodeToAddress(1)
        let id := decodeToUint(2)
        let amount := decodeToUint(3)

        let dataPointer, dataLength := decodeToBytes(4)

        // let dataPointer := calldataload(add(0x84, 0x04))
        // let dataLength := calldataload(dataPointer)
        calldatacopy(0x00, add(dataPointer, 0x24), dataLength)

        mstore(0x00, dataLength)
        return(0x00, 0x20)
      }
    //   case 0x61fefc8f /* "decodeToBytes(uint256)" */ {
    //     let dataPointer, dataLength := decodeToBytes(0)
    //     let freeMemPointer := mload(0x40)

    //     mstore(freeMemPointer, dataLength)
    //     calldatacopy(add(freeMemPointer, 0x20), dataPointer, dataLength)
    //     mstore(0x40, add(freeMemPointer, add(dataLength, 0x20)))

    //     return(freeMemPointer, add(dataLength, 0x20))
    //   }
      case 0x61fefc8f /* "decodeToBytes(uint256)" */ {
        let dataPointer, dataLength := decodeToBytes(0)

        let freeMemPointer := mload(0x40)
        mstore(freeMemPointer, dataLength)

        calldatacopy(add(freeMemPointer, 0x20), dataPointer, dataLength)
        mstore(0x40, add(freeMemPointer, add(0x20, dataLength)))

        return(freeMemPointer, add(0x20, dataLength))
      }
      default {
        revert(0, 0)
      }

      /* ---------- calldata decoding functions ----------- */
      function selector() -> s {
          s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
      }

      function decodeToAddress(offset) -> v {
        v := decodeToUint(offset)

        require(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff))))
      }

      function decodeToBytes(offset) -> dataPointer, dataLength {
        let pos := add(4, mul(offset, 0x20))
    
        if lt(calldatasize(), add(pos, 0x20)) {
         revert(0, 0)
        }

        dataPointer := calldataload(pos)

        if lt(calldatasize(), add(dataPointer, 0x20)) {
          revert(0, 0)
        }

        dataLength := calldataload(add(dataPointer, 0x04))

        if lt(calldatasize(), add(add(dataPointer, 0x20), dataLength)) {
            revert(0, 0)
        }

        dataPointer := add(dataPointer, 0x24)
      }

      function decodeToUint(offset) -> v {
        let pos := add(4, mul(offset, 0x20))
        if lt(calldatasize(), add(pos, 0x20)) {
          revert(0, 0)
        }
        v := calldataload(pos)
      }

      function require(condition) {
        if iszero(condition) { revert(0, 0) }
      }
    }
  }
}


// function safeTransferFrom     (address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
// function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;
// function balanceOf            (address _owner, uint256 _id) external view returns (uint256);
// function setApprovalForAll    (address _operator, bool _approved) external;
// function isApprovedForAll     (address _owner, address _operator) external view returns (bool);

// function balanceOfBatch       (address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);