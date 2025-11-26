// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntegerToRoman {
    /**
     * @dev 将整数转换为罗马数字
     * @param num 要转换的整数（1-3999）
     * @return 对应的罗马数字字符串
     */
    function i2r(uint num) public pure returns (string memory) {
        require(num > 0 && num <= 3999, "Number out of range (1-3999)");

        // 定义数值-符号映射（从大到小排序）
        uint[13] memory values = [
            uint(1000), 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1
        ];
        string[13] memory symbols = [
            "M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"
        ];

        bytes memory roman = new bytes(15); // 最大长度: "MMMCMXCIX" (9字符)
        uint pos = 0;
        uint index = 0;

        while (num > 0) {
            if (num >= values[index]) {
                // 追加对应符号
                bytes memory symbol = bytes(symbols[index]);
                for (uint j = 0; j < symbol.length; j++) {
                    roman[pos] = symbol[j];
                    pos++;
                }
                num -= values[index];
            } else {
                index++;
            }
        }

        return string(roman);
    }
}