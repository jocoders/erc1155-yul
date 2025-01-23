object "ERC1155Yul" {
  code {
    datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
    return(0, datasize("Runtime"))
  }
  object "Runtime" {
    code {
      /* Protection against sending Ether */
      require(iszero(callvalue()))

      switch selector()
      /* setApprovalForAll(address,bool) */
      case 0xa22cb465 { 
        let operator := decodeToAddress(0)
        let approved := decodeToUint(1)
        let sender := caller()
        storeValue(sender, operator, approved)
        emitApprovalForAll(sender, operator, approved)
      }
      /* supportsInterface(bytes4 interfaceId) */
      case 0x01ffc9a7 { 
          // ERC165 Interface ID for ERC165
          // ERC165 Interface ID for ERC1155
          // ERC165 Interface ID for ERC1155MetadataURI
          let interfaceId := calldataload(0x04)
          let isSupported := or(or(eq(interfaceId, 0x01ffc9a7), eq(interfaceId, 0xd9b67a26)), eq(interfaceId, 0x0e89341c))
          mstore(0x00, isSupported)
          return(0x00, 0x20)
      }
      /* isApprovedForAll(address,address) */
      case 0xe985e9c5 {
        let owner := decodeToAddress(0)
        let operator := decodeToAddress(1)
        let isApproved := getStoredVal(owner, operator)
        mstore(0x00, isApproved)
        return(0x00, 0x20)
      }
      /* mint(address,uint256,uint256,bytes) */
      case 0x731133e9 {
        let sender := caller()
        let to := decodeToAddress(0)
        let id := decodeToUint(1)
        let amount := decodeToUint(2)
        let balanceTo := getStoredVal(to, id)
        let newBalanceTo := safeAdd(balanceTo, amount)
        storeValue(to, id, newBalanceTo)
        validateERC1155Recipient(sender, 0x00, to, id, amount, 0x64)
      }
      /* batchMint(address,uint256[],uint256[],bytes) */
      case 0xb48ab8b6 {
        let sender := caller()
        let to := decodeToAddress(0)

        let idsOffset := add(calldataload(0x24), 0x04)
        let amountsOffset := add(calldataload(0x44), 0x04)

        let idsLength := calldataload(idsOffset)
        let amountsLength := calldataload(amountsOffset)
        checkLengthsEqual(idsLength, amountsLength)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let id := calldataload(add(add(idsOffset, 0x20), mul(i, 0x20)))
          let amount := calldataload(add(add(amountsOffset, 0x20), mul(i, 0x20)))

          let balanceTo := getStoredVal(to, id)
          let newBalanceTo := safeAdd(balanceTo, amount)
          storeValue(to, id, newBalanceTo)
        }
        validateERC1155BatchRecipient(sender, 0x00, to, 0x24)
      }
      /* burn(address,uint256,uint256) */
      case 0xf5298aca {
        let from := decodeToAddress(0)
        let id := decodeToUint(1)
        let amount := decodeToUint(2)
        let balanceFrom := getStoredVal(from, id)
        let newBalanceFrom := safeSub(balanceFrom, amount)
        storeValue(from, id, newBalanceFrom)
        emitTransferSingle(caller(), from, 0x00, id, amount)
      }
      /* batchBurn(address,uint256[],uint256[]) */
      case 0xf6eb127a {
        let sender := caller()
        let from := decodeToAddress(0)

        let idsOffset := add(calldataload(0x24), 0x04)
        let amountsOffset := add(calldataload(0x44), 0x04)

        let idsLength := calldataload(idsOffset)
        let amountsLength := calldataload(amountsOffset)
        checkLengthsEqual(idsLength, amountsLength)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let id := calldataload(add(add(idsOffset, 0x20), mul(i, 0x20)))
          let amount := calldataload(add(add(amountsOffset, 0x20), mul(i, 0x20)))

          let balanceFrom := getStoredVal(from, id)
          let newBalanceFrom := safeSub(balanceFrom, amount)
          storeValue(from, id, newBalanceFrom)
        }
        emitTransferBatch(sender, from, 0x00, idsOffset)
      }
      /* balanceOfBatch(address[],uint256[])*/
      case 0x4e1273f4 {
        let accOffset := add(calldataload(0x04), 0x04) 
        let idsOffset := add(calldataload(0x24), 0x04)

        let accLength := calldataload(accOffset)
        let idsLength := calldataload(idsOffset)
        checkLengthsEqual(accLength, idsLength)

        let mptr := 0x80
        mstore(mptr, 0x20)
        mptr := add(mptr, 0x20)

        mstore(mptr, idsLength)
        mptr := add(mptr, 0x20)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let owner := calldataload(add(add(accOffset, 0x20), mul(i, 0x20)))
          let id := calldataload(add(add(idsOffset, 0x20), mul(i, 0x20)))

          let balanceOf := getStoredVal(owner, id)
          let endMptr := add(mptr, mul(i, 0x20))
          mstore(endMptr, balanceOf)
        }

        return(0x80, add(mul(idsLength, 0x20), 0x40))
      }
      /* safeTransferFrom(address,address,uint256,uint256,bytes) */
      case 0xf242432a  {
        let from := decodeToAddress(0)
        checkIsAuthorized(from)

        let to := decodeToAddress(1)
        let id := decodeToUint(2)
        let amount := decodeToUint(3)
        let balanceFrom := getStoredVal(from, id)
        let newBalanceFrom := safeSub(balanceFrom, amount)
        storeValue(from, id, newBalanceFrom)

        let balanceTo := getStoredVal(to, id)
        let newBalanceTo := safeAdd(balanceTo, amount)
        storeValue(to, id, newBalanceTo)
        validateERC1155Recipient(caller(), from, to, id, amount, 0x84)
      }
      /* safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) */
      case 0x2eb2c2d6 {
        let sender := caller()
        let from := decodeToAddress(0)
        let to := decodeToAddress(1)

        let idsOffset := add(calldataload(0x44), 0x04)
        let amountsOffset := add(calldataload(0x64), 0x04)

        let idsLength := calldataload(idsOffset)
        let amountsLength := calldataload(amountsOffset)
        checkLengthsEqual(idsLength, amountsLength)
        checkIsAuthorized(from)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let id := calldataload(add(add(idsOffset, 0x20), mul(i, 0x20)))
          let amount := calldataload(add(add(amountsOffset, 0x20), mul(i, 0x20)))

          let balanceFrom := getStoredVal(from, id)
          let newBalanceFrom := safeSub(balanceFrom, amount)
          storeValue(from, id, newBalanceFrom)

          let balanceTo := getStoredVal(to, id)
          let newBalanceTo := safeAdd(balanceTo, amount)
          storeValue(to, id, newBalanceTo)
        }
 
        validateERC1155BatchRecipient(sender, from, to, idsOffset)
      }
      default {
        revert(0, 0)
      }

      /* ------------------------------ ERC1155 recipient validators ------------------------------ */
      function validateERC1155Recipient(sender, from, to, id, amount, dataPoint) {
        if iszero(extcodesize(to)) {
            require(to)
        }

        if extcodesize(to) {
          mstore(0x00, 0xf23a6e61)
          mstore(0x20, sender)
          mstore(0x40, from)
          mstore(0x60, id)
          mstore(0x80, amount)
          mstore(0xa0, 0xa0)
          
          let dataOffset := calldataload(dataPoint)
          let dataLength := calldataload(add(dataOffset, 0x04))
          mstore(0xc0, dataLength)
          calldatacopy(0xe0, add(dataPoint, 0x40), dataLength)

          let argSize := add(0xe0, dataLength)
          let success := call(gas(), to, 0, 0x1c, argSize, 0x00, 0x20)
          require(success)

          let retSelector := shr(224, mload(0x00))
          require(eq(retSelector, 0xf23a6e61))
        }

        emitTransferSingle(sender, from, to, id, amount)
      }

      function validateERC1155BatchRecipient(sender, from, to, idsOffset) {
        if iszero(extcodesize(to)) {
          require(to)
        }

        if extcodesize(to) {
          mstore(0x00, 0xbc197c81)
          mstore(0x20, sender)
          mstore(0x40, from)
          mstore(0x60, 0xc0) 
          
          let newMptr := copyDataToMemory(0xc0, idsOffset)
          mstore(0x80, newMptr)

          let newMptr2 := copyDataToMemory(newMptr, add(idsOffset, 0x20))
          mstore(0xa0, newMptr2)

          let newMptr3 := copyBytesToMem(newMptr2, add(idsOffset, 0x40))
          let success := call(gas(), to, 0, 0x1c, newMptr3, 0x00, 0x20)

          require(success)

          let retSelector := shr(224, mload(0x00))
          require(eq(retSelector, 0xbc197c81))
        }
        emitTransferBatch(sender, from, to, idsOffset)
      }

      function getStoredVal(key1, key2) -> val {
        mstore(0x00, key1)
        mstore(0x20, key2)
        val := sload(keccak256(0x00, 0x40))
      }

      /* ------------------------------ modifiers ------------------------------ */
      function checkIsAuthorized(from) {
        let sender := caller()
        mstore(0x00, from)
        mstore(0x20, sender)
        let condition := or(eq(from, sender), sload(keccak256(0x00, 0x40)))
        require(condition)
      }

      function checkLengthsEqual(idsLength, amountsLength) {
        require(eq(idsLength, amountsLength))
      }

      function storeValue(key1, key2, val) {
        mstore(0x00, key1)
        mstore(0x20, key2)
        sstore(keccak256(0x00, 0x40), val)
      }

      function require(condition) {
        if iszero(condition) { revert(0, 0) }
      }

      /* ------------------------------ decoders ------------------------------ */
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

      function copyDataToMemory(mptr, offset) -> newMptr {
          let dataOffset := add(calldataload(offset), 0x04)
          let length := calldataload(dataOffset)

          mstore(mptr, length)
          calldatacopy(add(mptr, 0x20), add(dataOffset, 0x20), length)
          newMptr := add(add(mptr, 0x20), length)
      }

      function copyBytesToMem(mptr, offset) -> newMptr {
          let dataOffset := add(calldataload(offset), 0x04)
          let length := calldataload(dataOffset)

          let totalLen := add(0x20, length)
          let rem := mod(length, 0x20)
          if rem {
            totalLen := add(totalLen, sub(0x20, rem))
          }
         calldatacopy(mptr, dataOffset, totalLen)
         newMptr := add(mptr, totalLen)
      }

      /* ------------------------------ math helpers ------------------------------ */
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

      /* ------------------------------ events ------------------------------ */
      /* URI(value,uint256) */
      function emitUri(id, offset) {
        let sigHash := 0xb7de062599403b33008eebf57e50130d39390f9116d4540c609ce417931d1f6c
        mstore(0x00, 0x20)

        let mptr := copyDataToMemory(0x20, offset)
        log2(0, mptr, sigHash, id)
      }

      /* TransferSingle(address,address,address,uint256,uint256) */
      function emitTransferSingle(operator, from, to, id, amount) {
        let sigHash := 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62
        mstore(0x00, id)
        mstore(0x20, amount)
        log4(0, 0x40, sigHash, operator, from, to)
      }
      
      /* ApprovalForAll(address,address,bool) */
      function emitApprovalForAll(owner, operator, approved) {
        let sigHash := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
        mstore(0x00, approved)
        log3(0, 0x20, sigHash, owner, operator)
      }

      /* TransferBatch(address,address,address,uint256[],uint256[]) */
      function emitTransferBatch(operator, from, to, idsOffset) {
        let sigHash := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb

        mstore(0x00, 0x40) // idsOffset

        let amoutMptr := copyDataToMemory(0x40, idsOffset) 
        mstore(0x20, amoutMptr) // amOffset

        let endMptr := copyDataToMemory(amoutMptr, add(idsOffset, 0x20))
        log4(0x00, endMptr, sigHash, operator, from, to)
      }

      /* ------------------------------ reverts ------------------------------ */
      /* "ERC1155: not authorized" */
      function revertNotAuthorized() {
        mstore(0x00, 0x8c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0x20, 0x40)
        mstore(0x40, 0x17) 
        mstore(0x60, 0x455243313135353a206e6f7420617574686f72697a6564000000000000000000)
        revert(0x00, 0x80) 
      }

      /* "ERC1155: unsafe recipient" */
      function revertUnsafeRecipient() {
        mstore(0x00, 0x8c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0x20, 0x40)
        mstore(0x40, 0x19) 
        mstore(0x60, 0x455243313135353a20756e7361666520726563697069656e7400000000000000)
        revert(0x00, 0x80) 
      }

      /* "ERC1155: length mismatch" */
      function revertLengthMismatch() {
        mstore(0x00, 0x8c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0x20, 0x40)
        mstore(0x40, 0x18) 
        mstore(0x60, 0x455243313135353a206c656e677468206d69736d617463680000000000000000)
        revert(0x00, 0x80) 
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