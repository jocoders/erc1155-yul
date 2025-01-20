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
        storeVal(sender, operator, approved)
        emitApprovalForAll(sender, operator, approved)
      }
      /* supportsInterface(bytes4 interfaceId) */
      case 0x01ffc9a7 { 
          // ERC165 Interface ID for ERC165
          // ERC165 Interface ID for ERC1155
          // ERC165 Interface ID for ERC1155MetadataURI
          let interfaceId := calldataload(0x04)
          let b := or(or(eq(interfaceId, 0x01ffc9a7), eq(interfaceId, 0xd9b67a26)), eq(interfaceId, 0x0e89341c))
          mstore(0x00, b)
          return(0x00, 0x20)
      }
      /* isApprovedForAll(address,address) */
      case 0xe985e9c5 {
        let owner := decodeToAddress(0)
        let operator := decodeToAddress(1)
        let val := getVal(owner, operator)
        mstore(0x00, val)
        return(0x00, 0x20)
      }
      /* mint(address,uint256,uint256,bytes) */
      case 0x731133e9 {
        let sender := caller()
        let to := decodeToAddress(0)
        let id := decodeToUint(1)
        let amount := decodeToUint(2)
        let balanceTo := getVal(to, id)
        let newBalanceTo := safeAdd(balanceTo, amount)
        storeVal(to, id, newBalanceTo)
        validateERC1155Recipient(sender, 0x00, to, id, amount, 0x64)
      }
      /* batchMint(address,uint256[],uint256[],bytes) */
      case 0xb48ab8b6 {
        let sender := caller()
        let to := decodeToAddress(0)
        let idsOffset := calldataload(0x24)
        let amountsOffset := calldataload(0x44)
        let idsLength := calldataload(add(idsOffset, 0x04))
        let amountsLength := calldataload(add(amountsOffset, 0x04))
        checkLengthsEqual(idsLength, amountsLength)

        let idOffset := add(idsOffset, 0x24)
        let amountOffset := add(amountsOffset, 0x24)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          // balanceOf[to][ids[i]] += amounts[i];
          let id := calldataload(add(idOffset, mul(i, 0x20)))
          let amount := calldataload(add(amountOffset, mul(i, 0x20)))

          let bal := getVal(to, id)
          let newBal := safeAdd(bal, amount)
          storeVal(to, id, newBal)
        }
        validateERC1155BatchRecipient(sender, 0x00, to, 0x24, 0x44)
      }
      /* burn(address,uint256,uint256) */
      case 0xf5298aca {
        let from := decodeToAddress(0)
        let id := decodeToUint(1)
        let amount := decodeToUint(2)
        let balanceFrom := getVal(from, id)
        let newBalanceFrom := safeSub(balanceFrom, amount)
        storeVal(from, id, newBalanceFrom)
        emitTransferSingle(caller(), from, 0x00, id, amount)
      }
      /* batchBurn(address,uint256[],uint256[]) */
      case 0xf6eb127a {
        let sender := caller()
        let from := decodeToAddress(0)
        let idsOffset := calldataload(0x24)
        let amountsOffset := calldataload(0x44)
        let idsLength := calldataload(add(idsOffset, 0x04))
        let amountsLength := calldataload(add(amountsOffset, 0x04))
        checkLengthsEqual(idsLength, amountsLength)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          // balanceOf[from][ids[i]] -= amounts[i];
          let id := calldataload(add(idsOffset, mul(i, 0x20)))
          let amount := calldataload(add(amountsOffset, mul(i, 0x20)))
          let bal := getVal(from, id)
          let newBal := safeSub(bal, amount)
          storeVal(from, id, newBal)
        }
        emitTransferBatch(sender, from, 0x00, idsOffset, amountsOffset)
      }
      /* balanceOfBatch(address[],uint256[])*/
      case 0x4e1273f4 {
        let accOffset := calldataload(0x04) 
        let idsOffset := calldataload(0x24)
        let accountsLength := calldataload(add(accOffset, 0x04))
        let idsLength := calldataload(add(idsOffset, 0x04))
        checkLengthsEqual(accountsLength, idsLength)

        let accDataOffset := add(add(accOffset, 0x04), 0x20)
        let idsDataOffset := add(add(idsOffset, 0x04), 0x20)

        let mptr := 0x80
        mstore(mptr, 0x20)
        mptr := add(mptr, 0x20)

        mstore(mptr, idsLength)
        mptr := add(mptr, 0x20)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let owner := calldataload(add(accDataOffset, mul(i, 0x20)))
          let id := calldataload(add(idsDataOffset, mul(i, 0x20)))
          let bal := getVal(owner, id)
          let sPtr := add(mptr, mul(i, 0x20))
          mstore(sPtr, bal)
        }

        let retLength := add(mul(idsLength, 0x20), 0x40)

        return(0x80, retLength)
      }
      /* safeTransferFrom(address,address,uint256,uint256,bytes) */
      case 0xf242432a  {
        let from := decodeToAddress(0)
        checkIsAuthorized(from)

        let to := decodeToAddress(1)
        let id := decodeToUint(2)
        let amount := decodeToUint(3)
        let balanceFrom := getVal(from, id)
        let newBalanceFrom := safeSub(balanceFrom, amount)
        storeVal(from, id, newBalanceFrom)

        let balanceTo := getVal(to, id)
        let newBalanceTo := safeAdd(balanceTo, amount)
        storeVal(to, id, newBalanceTo)
        validateERC1155Recipient(caller(), from, to, id, amount, 0x84)
      }
      /* safeBatchTransferFrom(address,address,uint256[],uint256[],bytes) */
      case 0x2eb2c2d6 {
        let sender := caller()
        let from := decodeToAddress(0)
        let to := decodeToAddress(1)
        let idsOffset := calldataload(0x44)
        let amountsOffset := calldataload(0x64)
        let idsLength := calldataload(add(idsOffset, 0x04))
        let amountsLength := calldataload(add(amountsOffset, 0x04))
        checkLengthsEqual(idsLength, amountsLength)
        checkIsAuthorized(from)

        for { let i := 0} lt(i, idsLength) { i := add(i, 1)} {
          let id := calldataload(add(idsOffset, mul(i, 0x20)))
          let amount := calldataload(add(amountsOffset, mul(i, 0x20)))

          let balanceFrom := getVal(from, id)
          let newBalanceFrom := safeSub(balanceFrom, amount)
          storeVal(from, id, newBalanceFrom)

          let balanceTo := getVal(to, id)
          let newBalanceTo := safeAdd(balanceTo, amount)
          storeVal(to, id, newBalanceTo)
        }
 
        //validateERC1155BatchRecipient(sender, from, to, idsOffset, amountsOffset)
      }
      case 0xa26388bb {
        revertNotAuthorized()
      }
      default {
        revert(0, 0)
      }

      // /* ---------- ERC1155 recipient validation ----------- */
    
      function validateERC1155Recipient(sender, from, to, id, amount, offset) {
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
          
          let dataOffset := calldataload(offset)
          let dataLength := calldataload(add(dataOffset, 0x04))
          mstore(0xc0, dataLength)
          calldatacopy(0xe0, 0xc4, dataLength)

          let argSize := add(0xe0, dataLength)
          let success := call(gas(), to, 0, 0x1c, argSize, 0x00, 0x20)
          require(success)

          let retSelector := shr(224, mload(0x00))
          require(eq(retSelector, 0xf23a6e61))
        }

        emitTransferSingle(sender, from, to, id, amount)
      }
      function validateERC1155BatchRecipient(sender, from, to, offset1, offset2) {
        if iszero(extcodesize(to)) {
          require(to)
        }

       // batchMint                            (address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        // safeBatchTransferFrom( address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data)

        if extcodesize(to) {
          mstore(0x00, 0xbc197c81)
          mstore(0x20, sender)
          mstore(0x40, from)
          mstore(0x60, 0x60)





          let dynDataLength := sub(calldatasize(), 0x24)
          calldatacopy(0x60, 0x24, dynDataLength)
          let argSize := add(0x60, dynDataLength)
          let success := call(gas(), to, 0, 0x1c, argSize, 0x00, 0x20)
          // require(success)

          // let retSelector := shr(224, mload(0x00))
          // require(eq(retSelector, 0xbc197c81))
        }

        //emitTransferBatch(sender, from, to, idsOffset, amountsOffset)
      }

      function getVal(key1, key2) -> val {
        mstore(0x00, key1)
        mstore(0x20, key2)
        val := sload(keccak256(0x00, 0x40))
      }
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
      function storeVal(key1, key2, val) {
        mstore(0x00, key1)
        mstore(0x20, key2)
        sstore(keccak256(0x00, 0x40), val)
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

      /* ---------- math helpers ----------- */
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
      function callDataCopy(mptr, arrOffset) -> newMptr {
        let arrLenOffset := add(arrOffset, 4)
        let arrLen := calldataload(arrLenOffset)
        let totalLen := add(0x20, mul(arrLen, 0x20)) // len+arrData
        calldatacopy(mptr, arrLenOffset, totalLen) // copy len+data to mptr

        newMptr := add(mptr, totalLen)
      }

      /* ---------- require ----------- */
      function require(condition) {
        if iszero(condition) { revert(0, 0) }
      }
      /* ---------- events ----------- */
      // // URI(value,uint256)
      // function emitUri(val, id) {
      //   let sigHash := 0xb7de062599403b33008eebf57e50130d39390f9116d4540c609ce417931d1f6c
      //   mstore(0x00, val)
      //   log2(0, 0x20, sigHash, id)
      // }

      // TransferSingle(address,address,address,uint256,uint256)
      function emitTransferSingle(operator, from, to, id, amount) {
        let sigHash := 0xc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62
        mstore(0x00, id)
        mstore(0x20, amount)
        log4(0, 0x40, sigHash, operator, from, to)
      }
      // ApprovalForAll(address,address,bool)
      function emitApprovalForAll(owner, operator, approved) {
        let sigHash := 0x17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31
        mstore(0x00, approved)
        log3(0, 0x20, sigHash, owner, operator)
      }
      // TransferBatch(address,address,address,uint256[],uint256[])
      function emitTransferBatch(operator, from, to, idsOffset, valuesOffset) {
        let sigHash := 0x4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb
        let oldMptr := mload(0x40)
        let mptr := oldMptr
        let idsOffsetPtr := mptr
        let valuesOffsetPtr := add(mptr, 0x20)

        mstore(idsOffsetPtr, 0x40) // ids offset
        let valuesPtr := callDataCopy(add(mptr, 0x40), idsOffset) // copy ids arary to memory
        mstore(valuesOffsetPtr, sub(valuesPtr, oldMptr)) // store values Offset
        let endPtr := callDataCopy(valuesPtr, valuesOffset) // copy values array to memory

        log4(oldMptr, sub(endPtr, oldMptr), sigHash, operator, from, to)
        mstore(0x40, endPtr) // update Free Memory Pointer
      }


      /* ---------- reverts ----------- */
      function revertNotAuthorized() {
        /* "ERC1155: not authorized" */
        let mptr := 0x00
        mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
        mstore(add(mptr, 0x04), 0x20)
        mstore(add(mptr, 0x24), 0x17) 
        mstore(add(mptr, 0x44), 0x455243313135353a206e6f7420617574686f72697a6564000000000000000000)
        revert(mptr, 0x64) 
      }

      function revertUnsafeRecipient() {
        /* "ERC1155: unsafe recipient" */
        let mptr := 0x00
        mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
        mstore(add(mptr, 0x04), 0x20)
        mstore(add(mptr, 0x24), 0x19) 
        mstore(add(mptr, 0x44), 0x455243313135353a20756e7361666520726563697069656e7400000000000000)
        revert(mptr, 0x64) 
      }

      function revertLengthMismatch() {
        /* "ERC1155: length mismatch" */
        let mptr := 0x00
        mstore(mptr, 0x8c379a000000000000000000000000000000000000000000000000000000000)
        mstore(add(mptr, 0x04), 0x20)
        mstore(add(mptr, 0x24), 0x18) 
        mstore(add(mptr, 0x44), 0x455243313135353a206c656e677468206d69736d617463680000000000000000)
        revert(mptr, 0x64) 
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