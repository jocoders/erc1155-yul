object "ERC1155Yul" {
  code {
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime" {
    code {
      switch selector()
      /*✦✧✶✧✦* supportsInterface(bytes4 interfaceId) *✦✧✶✧✦*/
      case 0x01ffc9a7 { 
        let interfaceId := shr(224, calldataload(0x04))
       let isSupported

        switch interfaceId
        case 0x01ffc9a7 { isSupported := 1 } 
        case 0xd9b67a26 { isSupported := 1 } 
        case 0x0e89341c { isSupported := 1 } 
        default { isSupported := 0 } 

        mstore(0x00, isSupported)
        return(0x00, 0x20)
      }
      /*✦✧✶✧✦* isApprovedForAll(address,address) *✦✧✶✧✦*/
      case 0xe985e9c5 {
        let owner := decodeToAddress(0)
        let operator := decodeToAddress(1)
        let isApproved := getStoredValue(owner, operator)

        mstore(0x00, isApproved)
        return(0x00, 0x20)
      }
      /*✦✧✶✧✦* setApprovalForAll(address,bool) *✦✧✶✧✦*/
      case 0xa22cb465 { 
        let operator := decodeToAddress(0)
        let approved := decodeToUint(1)
        let sender := caller()

        storeValue(sender, operator, approved)
        emitApprovalForAll(sender, operator, approved)
      }
      /*✦✧✶✧✦* mint(address,uint256,uint256,bytes) *✦✧✶✧✦*/
      case 0x731133e9 {
        let to := decodeToAddress(0)
        let id := decodeToUint(1)
        let amount := decodeToUint(2)
        let balanceTo := getStoredValue(to, id)
        let newBalanceTo := safeAdd(balanceTo, amount)

        storeValue(to, id, newBalanceTo)
        validateERC1155Recipient(0x00, to, id, amount, 0x64)
      }
      /*✦✧✶✧✦* batchMint(address,uint256[],uint256[],bytes) *✦✧✶✧✦*/
      case 0xb48ab8b6 {
        let to := decodeToAddress(0)
        let idsOffset := add(calldataload(0x24), 0x04)
        let amountsOffset := add(calldataload(0x44), 0x04)

        let idsLength := calldataload(idsOffset)
        let amountsLength := calldataload(amountsOffset)
        checkLengthsAreEqual(idsLength, amountsLength)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let id := getIndexValue(idsOffset, i) 
          let amount := getIndexValue(amountsOffset, i) 

          let balanceTo := getStoredValue(to, id)
          let newBalanceTo := safeAdd(balanceTo, amount)
          storeValue(to, id, newBalanceTo)
        }
        validateERC1155BatchRecipient(0x00, to, 0x24, 0x44, 0x64)
      }
      /*✦✧✶✧✦* burn(address,uint256,uint256) *✦✧✶✧✦*/
      case 0xf5298aca {
        let from := decodeToAddress(0)
        let id := decodeToUint(1)
        let amount := decodeToUint(2)

        let balanceFrom := getStoredValue(from, id)
        let newBalanceFrom := safeSub(balanceFrom, amount)

        storeValue(from, id, newBalanceFrom)
        emitTransferSingle(caller(), from, 0x00, id, amount)
      }
      /*✦✧✶✧✦* batchBurn(address,uint256[],uint256[]) *✦✧✶✧✦*/
      case 0xf6eb127a {
        let from := decodeToAddress(0)
        let idsOffset := add(calldataload(0x24), 0x04)
        let amountsOffset := add(calldataload(0x44), 0x04)

        let idsLength := calldataload(idsOffset)
        let amountsLength := calldataload(amountsOffset)
        checkLengthsAreEqual(idsLength, amountsLength)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let id := getIndexValue(idsOffset, i) 
          let amount := getIndexValue(amountsOffset, i) 

          let balanceFrom := getStoredValue(from, id)
          let newBalanceFrom := safeSub(balanceFrom, amount)
          storeValue(from, id, newBalanceFrom)
        }
        emitTransferBatch(caller(), from, 0x00, idsOffset)
      }
      /*✦✧✶✧✦* balanceOfBatch(address[],uint256[]) *✦✧✶✧✦*/
      case 0x4e1273f4 {
        let accOffset := add(calldataload(0x04), 0x04) 
        let idsOffset := add(calldataload(0x24), 0x04)
        let accLength := calldataload(accOffset)
        let idsLength := calldataload(idsOffset)
        checkLengthsAreEqual(accLength, idsLength)

        let offset := 0x80
        mstore(offset, 0x20)
        offset := add(offset, 0x20)

        mstore(offset, idsLength)
        offset := add(offset, 0x20)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let owner := getIndexValue(accOffset, i)
          let id := getIndexValue(idsOffset, i)

          let balanceOf := getStoredValue(owner, id)
          let finalOffset := add(offset, mul(i, 0x20))
          mstore(finalOffset, balanceOf)
        }

        return(0x80, add(mul(idsLength, 0x20), 0x40))
      }
      /*✦✧✶✧✦* safeTransferFrom(address,address,uint256,uint256,bytes) *✦✧✶✧✦*/
      case 0xf242432a  {
        let from := decodeToAddress(0)
        checkIsAuthorized(from)

        let to := decodeToAddress(1)
        let id := decodeToUint(2)
        let amount := decodeToUint(3)

        let balanceFrom := getStoredValue(from, id)
        let newBalanceFrom := safeSub(balanceFrom, amount)
        storeValue(from, id, newBalanceFrom)

        let balanceTo := getStoredValue(to, id)
        let newBalanceTo := safeAdd(balanceTo, amount)
        storeValue(to, id, newBalanceTo)
        validateERC1155Recipient(from, to, id, amount, 0x84)
      }
      /*✦✧✶✧✦* safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) *✦✧✶✧✦*/
      case 0x2eb2c2d6 {
        let from := decodeToAddress(0)
        let to := decodeToAddress(1)

        let idsOffset := add(calldataload(0x44), 0x04)
        let amountsOffset := add(calldataload(0x64), 0x04)

        let idsLength := calldataload(idsOffset)
        let amountsLength := calldataload(amountsOffset)
        checkLengthsAreEqual(idsLength, amountsLength)
        checkIsAuthorized(from)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let id := getIndexValue(idsOffset, i) 
          let amount := getIndexValue(amountsOffset, i)

          let balanceFrom := getStoredValue(from, id)
          let newBalanceFrom := safeSub(balanceFrom, amount)
          storeValue(from, id, newBalanceFrom)

          let balanceTo := getStoredValue(to, id)
          let newBalanceTo := safeAdd(balanceTo, amount)
          storeValue(to, id, newBalanceTo)
        }
 
        validateERC1155BatchRecipient(from, to, 0x44, 0x64, 0x84)
      }
      default {
        revert(0, 0)
      }

      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      /*              ERC1155 recipient validators        */
      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      function validateERC1155Recipient(from, to, id, amount, dataOffsetPointer) {
        let sender := caller()

        switch gt(extcodesize(to), 0)
        case 1 {
          mstore(0x00, 0xf23a6e61) // store selector onERC1155Received(address,address,uint256,uint256,bytes)
          mstore(0x20, sender)
          mstore(0x40, from)
          mstore(0x60, id)
          mstore(0x80, amount)
          mstore(0xa0, 0xa0) // store bytes data offset
          
          let dataOffset := calldataload(dataOffsetPointer)
          let dataLength := calldataload(add(dataOffset, 0x04))
          mstore(0xc0, dataLength)
          calldatacopy(0xe0, add(dataOffsetPointer, 0x40), dataLength) // store bytes data to memory

          let argSize := add(0xe0, dataLength)
          let success := call(gas(), to, 0, 0x1c, argSize, 0x00, 0x20)
          require(success)

          let extractedSelector := shr(224, mload(0x00))

          if iszero(eq(extractedSelector, 0xf23a6e61)) {
            revertUnsafeRecipient()
          }
        }
        default {
          if eq(to, 0) {
            revertUnsafeRecipient()
          }
        }

        emitTransferSingle(sender, from, to, id, amount)
      }

      function validateERC1155BatchRecipient(from, to, idsOffsetPointer, amountOffsetPointer, bytesOffsetPointer) {
        let sender := caller()

        switch gt(extcodesize(to), 0)
        case 1 {
          mstore(0x00, 0xbc197c81) // store selector onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)
          mstore(0x20, sender)
          mstore(0x40, from)
          mstore(0x60, 0xc0) // save offset for ids[]

          let offset := copyDataToMemory(0xc0, idsOffsetPointer)
          mstore(0x80, offset) // save offset for amounts[]

          offset := copyDataToMemory(offset, amountOffsetPointer)
          mstore(0xa0, offset) // save offset for bytes[]

          offset := copyBytesToMemory(offset, bytesOffsetPointer)

          log1(0x00, offset, 0xbc197c81)

          // Variant with 0 offsets:
          // Bytes data input:
          // 0x35220b60aad3eb9d19432bd61fc61db3ccad8484a6a0d75f88f2950cc5ab6020
          //   878d723f871b0f090858397bbd30a22fb7009225d6a13fb4e0bb9e71941df855
          //   d5241854963c851dc5e5923dd3ac34b97ff10acf08e7c66697874c672f257350
          //   855b42

          // Decode data log from => log1(0x00, offset, 0xbc197c81):
          // 0x00000000000000000000000000000000000000000000000000000000bc197c81 --> [0x00-0x20]   selector 4 bytes
          //   0000000000000000000000007fa9385be102ac3eac297483dd6233d62b3e1496 --> [0x20-0x40]   sender address
          //   0000000000000000000000000000000000000000000000000000000000000000 --> [0x40-0x60]   from address 0 because mint
          //   00000000000000000000000000000000000000000000000000000000000000c0 --> [0x60-0x80]   offset for ids[]
          //   0000000000000000000000000000000000000000000000000000000000000140 --> [0x80-0xa0]   offset for amounts[]
          //   00000000000000000000000000000000000000000000000000000000000001c0 --> [0xa0-0xc0]   offset for bytes[]
          //   0000000000000000000000000000000000000000000000000000000000000003 --> [0xc0-0xe0]   ids length
          //   000000000000000000000000000000000000000000000000000000000000004d --> [0xe0-0x100]  77
          //   0000000000000000000000000000000000000000000000000000000000000058 --> [0x100-0x120] 88
          //   0000000000000000000000000000000000000000000000000000000000000063 --> [0x120-0x140] 99
          //   0000000000000000000000000000000000000000000000000000000000000003 --> [0x140-0x160] amounts length
          //   0000000000000000000000000000000000000000000000000000000000000309 --> [0x160-0x180] 777 
          //   0000000000000000000000000000000000000000000000000000000000000378 --> [0x180-0x1a0] 888
          //   00000000000000000000000000000000000000000000000000000000000003e7 --> [0x1a0-0x1c0] 999
          //   0000000000000000000000000000000000000000000000000000000000000063 --> [0x1c0-0x1e0] bytes data length
          //   35220b60aad3eb9d19432bd61fc61db3ccad8484a6a0d75f88f2950cc5ab6020 --> [0x1e0-LAST] bytes data
          //   878d723f871b0f090858397bbd30a22fb7009225d6a13fb4e0bb9e71941df855
          //   d5241854963c851dc5e5923dd3ac34b97ff10acf08e7c66697874c672f257350
          //   855b420000000000000000000000000000000000000000000000000000000000


          // Variant without 0 offsets:
          // Bytes data input:
          // 0xc7dc8e5d29ff238fad3d47fdc5d7f31f357ac3

          // Decode data log from => log1(0x00, offset, 0xbc197c81):
          // 0x00000000000000000000000000000000000000000000000000000000bc197c81 --> [0x00-0x20]   selector 4 bytes
          //   0000000000000000000000007fa9385be102ac3eac297483dd6233d62b3e1496 --> [0x20-0x40]   sender address  
          //   0000000000000000000000000000000000000000000000000000000000000000 --> [0x40-0x60]   from address 0 because mint
          //   00000000000000000000000000000000000000000000000000000000000000c0 --> [0x60-0x80]   offset for ids[]
          //   0000000000000000000000000000000000000000000000000000000000000140 --> [0x80-0xa0]   offset for amounts[]
          //   00000000000000000000000000000000000000000000000000000000000001c0 --> [0xa0-0xc0]   offset for bytes[]
          //   0000000000000000000000000000000000000000000000000000000000000003 --> [0xc0-0xe0]   ids length
          //   000000000000000000000000000000000000000000000000000000000000004d --> [0xe0-0x100]  77
          //   0000000000000000000000000000000000000000000000000000000000000058 --> [0x100-0x120] 88
          //   0000000000000000000000000000000000000000000000000000000000000063 --> [0x120-0x140] 99
          //   0000000000000000000000000000000000000000000000000000000000000003 --> [0x140-0x160] amounts length
          //   0000000000000000000000000000000000000000000000000000000000000309 --> [0x160-0x180] 777 
          //   0000000000000000000000000000000000000000000000000000000000000378 --> [0x180-0x1a0] 888
          //   00000000000000000000000000000000000000000000000000000000000003e7 --> [0x1a0-0x1c0] 999
          //   0000000000000000000000000000000000000000000000000000000000000013 --> [0x1c0-0x1e0] bytes data length
          //   c7dc8e5d29ff238fad3d47fdc5d7f31f357ac3                           --> [0x1e0-0x200] bytes data


          let success := call(gas(), to, 0, 0x1c, sub(offset, 0x1c), 0x00, 0x20)

          // require(success)

          // let extractedSelector := shr(224, mload(0x00))

          // if iszero(eq(extractedSelector, 0xbc197c81)) {
          //   revertUnsafeRecipient()
          // }

          // onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)
        }
        default {
          if eq(to, 0) {
            revertUnsafeRecipient()
          }
        }

        emitTransferBatch(sender, from, to, idsOffsetPointer)
      }

      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      /*                    Data validators               */
      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      function checkIsAuthorized(from) {
        let sender := caller()
        mstore(0x00, from)
        mstore(0x20, sender)

        let condition := or(eq(from, sender), sload(keccak256(0x00, 0x40)))

        if iszero(condition) {
          revertNotAuthorized()
        }
      }

      function checkLengthsAreEqual(length1, length2) {
        if iszero(eq(length1, length2)) {
          revertLengthMismatch()
        }
      }

      function require(condition) {
        if iszero(condition) { revert(0, 0) }
      }

      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      /*                    Storage helpers               */
      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      function storeValue(key1, key2, value) {
        mstore(0x00, key1)
        mstore(0x20, key2)
        sstore(keccak256(0x00, 0x40), value)
      }

      function getStoredValue(key1, key2) -> value {
        mstore(0x00, key1)
        mstore(0x20, key2)
        value := sload(keccak256(0x00, 0x40))
      }

      function getIndexValue(offset, index) -> value {
        value := calldataload(add(add(offset, 0x20), mul(index, 0x20)))
      }

      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      /*                        Decoders                  */
      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      function selector() -> value {
          value := shr(224, calldataload(0))
      }

      function decodeToAddress(position) -> value {
        value := decodeToUint(position)
        require(iszero(and(value, not(0xffffffffffffffffffffffffffffffffffffffff))))
      }

      function decodeToUint(position) -> value {
        let offset := add(4, mul(position, 0x20))

        if lt(calldatasize(), add(offset, 0x20)) {
          revert(0, 0)
        }
        value := calldataload(offset)
      }

      function copyDataToMemory(freeOffset, dataOffsetPointer) -> nextOffset {
        let dataOffset := add(calldataload(dataOffsetPointer), 0x04)
        let length := calldataload(dataOffset)

        calldatacopy(freeOffset, dataOffset, add(mul(length, 0x20), 0x20))
        nextOffset := add(freeOffset, add(mul(length, 0x20), 0x20))
      }

      function copyBytesToMemory(freeOffset, dataOffsetPointer) -> nextOffset {
        let dataOffset := add(calldataload(dataOffsetPointer), 0x04)
        let length := calldataload(dataOffset)

        let totalLength := add(0x20, length)
        let reminder := mod(length, 0x20)

        // if reminder {
        //   totalLength := add(totalLength, sub(0x20, reminder))
        // }

        calldatacopy(freeOffset, dataOffset, totalLength)
        nextOffset := add(freeOffset, totalLength)
      }

      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      /*                      Math helpers                */
      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      function safeSub(x, y) -> result {
        if iszero(iszero(gt(y, x))) {
          revert(0, 0)
        }
        result := sub(x, y)
      }

      function safeAdd(x, y) -> result {
        result := add(x, y)

        if iszero(gt(result, x)) {
          revert(0, 0)
        }
      }

      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      /*                         Events                   */
      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/

      /*✦✧✶✧✦* emitUri(uint256,uint256) *✦✧✶✧✦*/
      function emitUri(id, dataOffset) {
        let sigHash := 0xb7de062599403b33008eebf57e50130d39390f9116d4540c609ce417931d1f6c
        mstore(0x00, 0x20)

        let offset := copyDataToMemory(0x20, dataOffset)
        log2(0, offset, sigHash, id)
      }

      /*✦✧✶✧✦* emitTransferSingle(address,address,address,uint256,uint256) *✦✧✶✧✦*/
      function emitTransferSingle(operator, from, to, id, amount) {
        let sigHash := 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62
        mstore(0x00, id)
        mstore(0x20, amount)
        log4(0, 0x40, sigHash, operator, from, to)
      }
      
      /*✦✧✶✧✦* emitApprovalForAll(address,address,bool) *✦✧✶✧✦*/
      function emitApprovalForAll(owner, operator, isApproved) {
        let sigHash := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
        mstore(0x00, isApproved)
        log3(0, 0x20, sigHash, owner, operator)
      }

      /*✦✧✶✧✦* emitTransferBatch(address,address,address,uint256[]) *✦✧✶✧✦*/
      function emitTransferBatch(operator, from, to, dataOffset) {
        let sigHash := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb
        mstore(0x00, 0x40) 

        let offset := copyDataToMemory(0x40, dataOffset) 
        mstore(0x20, offset) 

        offset := copyDataToMemory(offset, add(dataOffset, 0x20))
        log4(0x00, offset, sigHash, operator, from, to)
      }

      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/
      /*                      Error reverts                     */
      /*✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦.•:*¨¨*:•.✦✧✶✧✦*/

      /*✦✧✶✧✦* revertNotAuthorized() *✦✧✶✧✦*/
      function revertNotAuthorized() {
        mstore(0x00, 0xea8e4eb5) 
        revert(0x00, 0x20) 
      }

      /*✦✧✶✧✦* revertUnsafeRecipient() *✦✧✶✧✦*/
      function revertUnsafeRecipient() {
        mstore(0x00, 0x3da63931)
        revert(0x00, 0x20) 
      }

      /*✦✧✶✧✦* revertLengthMismatch() *✦✧✶✧✦*/
      function revertLengthMismatch() {
        mstore(0x00, 0xff633a38)
        revert(0x00, 0x20) 
      }
    }
  }
}
