// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RomanToInteger {
    /**
     * @dev 获取单个罗马字符对应的整数值
     * @param romanChar 罗马字符（bytes1）
     * @return 对应的整数值
     */
    function getRomanValue(bytes1 romanChar) internal pure returns (uint) {
        if (romanChar == "I") return 1;
        if (romanChar == "V") return 5;
        if (romanChar == "X") return 10;
        if (romanChar == "L") return 50;
        if (romanChar == "C") return 100;
        if (romanChar == "D") return 500;
        if (romanChar == "M") return 1000;
        revert("Invalid Roman numeral");
    }

    /**
     * @dev 将罗马数字字符串转换为整数
     * @param rmNumber 罗马数字字符串
     * @return 转换后的整数值
     */
    function r2i(string calldata rmNumber) public pure returns (uint) {
        uint length = bytes(rmNumber).length;
        if (length == 0) revert("Empty string");

        uint total = 0;
        uint prevValue = 0;

        for (uint i = 0; i < length; i++) {
            uint currentValue = getRomanValue(bytes1(bytes(rmNumber)[i]));
            if (currentValue > prevValue) {
                total += currentValue - 2 * prevValue; // 撤销上次加法并应用减法规则
            } else {
                total += currentValue;
            }
            prevValue = currentValue;
        }

        return total;
    }
}