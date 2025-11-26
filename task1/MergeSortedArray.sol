// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MergeSortedArray {
    /**
     * @dev 合并两个已排序的 uint 数组
     * @param ar1 第一个有序数组（升序）
     * @param ar2 第二个有序数组（升序）
     * @return 合并后的有序数组
     */
    function merge(uint[] calldata ar1, uint[] calldata ar2) public  pure returns (uint[] memory)  {
        uint l1 = ar1.length;
        require(l1 > 0, "ar1.length cannot be 0!");
        uint l2 = ar2.length;
        require(l2 > 0, "ar2.length cannot be 0!");

        uint mgl = l1 + l2;
        uint[] memory merged = new uint[](mgl);
        uint i = 0;  // ar1 的索引
        uint j = 0;  // ar2 的索引
        uint k = 0;  // merged 的索引

        // 合并主循环
        while (i < l1 && j < l2) {
            if (ar1[i] <= ar2[j]) {
                merged[k] = ar1[i];
                i++;
            } else {
                merged[k] = ar2[j];
                j++;
            }
            k++;
        }

        // 复制 ar1 的剩余元素
        while (i < l1) {
            merged[k] = ar1[i];
            i++;
            k++;
        }

        // 复制 ar2 的剩余元素
        while (j < l2) {
            merged[k] = ar2[j];
            j++;
            k++;
        }

        return merged;
    }
}