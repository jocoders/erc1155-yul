object "ERC1155Yul" {
  code {
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime" {
    code {
      // Protection against sending Ether
      require(iszero(callvalue()))

      switch selector()
      /* setApprovalForAll(address,bool) */
      case 0xa22cb465 { 
        let operator := decodeToAddress(0)
        let approved := decodeToUint(1)
        let sender := caller()

        mstore(0x00, sender)
        mstore(0x20, operator)
        sstore(keccak256(0x00, 0x40), approved)

        // emit ApprovalForAll(address,address,bool)
        mstore(0x00, approved)
        log3(0, 0x20, 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31, sender, operator)
      }
      /* supportsInterface(bytes4 interfaceId) */
      case 0x01ffc9a7 { 
          let interfaceId := calldataload(0x04)
          // ERC165 Interface ID for ERC165
          // ERC165 Interface ID for ERC1155
          // ERC165 Interface ID for ERC1155MetadataURI
          let b := or(or(eq(interfaceId, 0x01ffc9a7), eq(interfaceId, 0xd9b67a26)), eq(interfaceId, 0x0e89341c))
          mstore(0x00, b)
          return(0x00, 0x20)
      }
      /* mint(address,uint256,uint256,bytes) */
      case 0x731133e9 {
        let to := decodeToAddress(0)
        let id := decodeToUint(1)
        let amount := decodeToUint(2)

        mstore(0x00, to)
        mstore(0x20, id)
        let balanceTo := sload(keccak256(0x00, 0x20))
        let newBalanceTo := safeAdd(balanceTo, amount)

        mstore(0x00, to)
        mstore(0x20, id)
        sstore(keccak256(0x00, 0x40), newBalanceTo)

        let sender := caller()
        // emit TransferSingle(address,address,uint256,uint256,bytes)
        mstore(0x00, id)
        mstore(0x20, amount)
        log4(0, 0x40, 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62, sender, 0x00, to)

        validateERC1155Recipient(sender, 0x00, to, id, amount)
      }
      /* burn(address,uint256,uint256) */
      case 0xf5298aca {
        let from := decodeToAddress(0)
        let id := decodeToUint(1)
        let amount := decodeToUint(2)

        mstore(0x00, from)
        mstore(0x20, id)
        let balanceFrom := sload(keccak256(0x00, 0x40))
        let newBalanceFrom := safeSub(balanceFrom, amount)

        mstore(0x00, from)
        mstore(0x20, id)
        sstore(keccak256(0x00, 0x40), newBalanceFrom)

        // emit TransferSingle(address,address,uint256,uint256,bytes)
        mstore(0x00, id)
        mstore(0x20, amount)
        log4(0, 0x40, 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62, caller(), from, 0x00)
      }
      /* safeTransferFrom(address,address,uint256,uint256,bytes) */
      case 0xf242432a  {
        let from := decodeToAddress(0)
        let sender := caller()

        mstore(0x00, from)
        mstore(0x20, sender)

        let condition := or(eq(from, sender), sload(keccak256(0x00, 0x40)))
        require(condition)

        let to := decodeToAddress(1)
        let id := decodeToUint(2)
        let amount := decodeToUint(3)

        mstore(0x00, from)
        mstore(0x20, id)
        let balanceFrom := sload(keccak256(0x00, 0x40))
        let newBalanceFrom := safeSub(balanceFrom, amount)

        mstore(0x00, from)
        mstore(0x20, id)
        sstore(keccak256(0x00, 0x40), newBalanceFrom)

        mstore(0x00, to)
        mstore(0x20, id)
        let balanceTo := sload(keccak256(0x00, 0x20))
        let newBalanceTo := safeAdd(balanceTo, amount)

        mstore(0x00, to)
        mstore(0x20, id)
        sstore(keccak256(0x00, 0x40), newBalanceTo)

        // emit TransferSingle(address,address,uint256,uint256,bytes)
        mstore(0x00, id)
        mstore(0x20, amount)
        log4(0, 0x40, 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62, sender, from, to)

        validateERC1155Recipient(sender, from, to, id, amount)
      }
      /* checkDecodeToUint(uint256) */
      case 0x7a8c9ddb  {
        let value := decodeToUint(0)
        let freeMemPointer := mload(0x40)
        mstore(freeMemPointer, value)

        return(freeMemPointer, 0x20)
      }
      /* checkDecodeToAddress(address) */
      case 0xa5ce3326  {
        let value := decodeToAddress(0)
        let freeMemPointer := mload(0x40)
        mstore(freeMemPointer, value)

        return(freeMemPointer, 0x20)
      }
      /* balanceOfBatch(address[],uint256[])*/
      case 0x4e1273f4 {
        let s7 := shr(224, calldataload(0x00))  // Извлечение селектора

        let accountsOffset := calldataload(0x04) // 0x40
        let idsOffset := calldataload(0x24)

        let accountsLength := calldataload(add(accountsOffset, 0x04))
        let idsLength := calldataload(add(idsOffset, 0x04))

        require(eq(accountsLength, idsLength))

        let p := mload(0x40)
        mstore(p, idsLength)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let owner := calldataload(add(accountsOffset, mul(i, 0x20)))
        }

        // let accountsLength := calldataload(accountsOffset)

        // let account1 := calldataload(add(accountsOffset, 0x20))
        // let account2 := calldataload(add(accountsOffset, 0x40))

        mstore(0x00, 0x01)  // 0               1                     2                   3
        log4(0, 0x20, calldataload(0x04), calldataload(0x24), calldataload(0x44), calldataload(0x64))

        mstore(0x00, 0x02)  // 0               1                     2                   3
        log4(0, 0x20, calldataload(0x84), calldataload(0xa4), calldataload(0xc4), calldataload(0xe4))

        mstore(0x00, 0x03)  // 0               1                     2                   3
        log4(0, 0x20, calldataload(0x104), calldataload(0x124), calldataload(0x144), calldataload(0x164))
      }
      default {
        revert(0, 0)
      }

      function validateERC1155Recipient(sender, from, to, id, amount) {
        if iszero(extcodesize(to)) {
          require(to)
        }

        if extcodesize(to) {
          /* onERC1155Received(address,address,uint256,uint256,bytes) */
          let p := mload(0x40)


          // 1) selector keep in 0x00-0x04 || 0x00-0x20

          // 2) need to save data offset for calldata? where to store it?
          // after selectore or after all data?

          // 3) argsOffset is it offset for start all data? It means after selector?

          // 4) argSize includes selector 4 bytes or no?

          mstore(p, 0xf23a6e61)
          mstore(add(p, 0x20), sender)
          mstore(add(p, 0x40), from)
          mstore(add(p, 0x60), id)
          mstore(add(p, 0x80), amount)


          let dataLength := calldataload(0x84)
          mstore(add(p, 0xa0), dataLength)

          calldatacopy(add(p, 0xc0), 0xa4, dataLength)

          let argSize := add(0xc0, dataLength)
          let success := call(gas(), to, 0, add(p, 0x1c), argSize, 0x00, 0x20)

          mstore(0x00, success)
          log4(0, 0x20, 0x173, dataLength, calldataload(0xa4), mload(0x20))

          // require(success)

          // if iszero(eq(0xf23a6e61, shr(224, mload(0x00)))) {
          //     mstore(0x00, 0xd1a57ed6)
          //     revert(0x1c, 0x04)    
          // }

          // require(call(gas(), to, 0, 0x00, add(0xc0, dataLength), 0x00, 0x20))
          // call(gas(), token, 0, callData, 0x64, 0, 0)
          // require(iszero(eq(returndatasize(), 0x20)))

          // returndatacopy(0x00, 0x00, 0x20)
          // require(eq(0x150b7a02, shr(224, mload(0x00))))
        }
      }
      /* ---------- calldata decoding functions ----------- */
      function selector() -> s {
          s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
      }

      function decodeToAddress(offset) -> v {
        v := decodeToUint(offset)

        require(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff))))
      }

      function decodeToUint(offset) -> v {
        let pos := add(4, mul(offset, 0x20))
        if lt(calldatasize(), add(pos, 0x20)) {
          revert(0, 0)
        }
        v := calldataload(pos)
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

      /* ---------- helpers functions ----------- */
      function safeSub(x, y) -> res {
        if iszero(iszero(gt(y, x))) {
          revert(0, 0)
        }
        res := sub(x, y)
      }

      function safeAdd(x, y) -> res {
        res := add(x, y)

        if iszero(gt(res, x)) {
          revert(0, 0)
        }
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