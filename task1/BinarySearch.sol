// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BinarySearch {
    /**
     * @dev 在有序数组中使用二分查找法查找目标值
     * @param arr 有序的 uint 数组（升序）
     * @param target 要查找的目标值
     * @return 目标值的索引（找到），或 -1（未找到）
     */
    function search(uint[] calldata arr, uint target) public   pure   returns (int) {
        uint left = 0;
        uint right = arr.length - 1;

        while (left <= right) {
            uint mid = left + (right - left) / 2; // 防止溢出

            if (arr[mid] == target) {
                return int(mid); // 找到目标值
            } else if (arr[mid] < target) {
                left = mid + 1; // 在右半部分查找
            } else {
                right = mid - 1; // 在左半部分查找
            }
        }

        return -1; // 未找到目标值
    }
}