// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ReverseString {
    /**
     * @dev 反转输入字符串
     * @param str 输入字符串
     * @return 反转后的字符串
     */
    function reverse(string calldata str) public pure  returns (string memory) {
        bytes memory strBytes = bytes(str);
        uint len = strBytes.length;
        require(len > 0, "String cannot be empty!");

        bytes memory reversedBytes = new bytes(len);

        for (uint i = 0; i < len; i++) {
            reversedBytes[i] = strBytes[len - 1 - i];
        }

        return string(reversedBytes);
    }
}