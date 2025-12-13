// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OptimizedBeggingContract {
    uint256 private _donationAmount;
    mapping(address => uint256) private _donation;
    address private _owner;

    // 核心数据结构变更：使用映射按金额分组存储地址，并维护一个唯一金额的数组
    mapping(uint256 => address[]) private _donorsByAmount; // 金额 => 地址列表
    uint256[] private _uniqueAmounts; // 存储所有出现过的捐款金额，用于排序

    uint256 private _endtimestamp;

    constructor(uint256 endtimestamp_) {
        _owner = msg.sender;
        _endtimestamp=endtimestamp_;
    }
    
    //合约权限拦截修饰
    modifier onlyOwner() {
        require(msg.sender == _owner, "No permission");
        _;
    }

    //捐款时限拦截修饰
    modifier endtimeLimitor(){
        require(block.timestamp<_endtimestamp,"Donations are closed");
        _;
    }

    //记录每次捐赠的地址和金额
    event Donation(address indexed from, uint256 indexed amount);
    
    //用户捐款
    function donate() external endtimeLimitor payable returns (bool) {
        uint256 amount = msg.value;
        require(amount > 0, "Donation amount must be greater than 0");

        address donor = msg.sender;
        uint256 oldAmount = _donation[donor];
        uint256 newAmount = oldAmount + amount;

        // 更新总捐款额和捐款者金额
        _donationAmount += amount;
        _donation[donor] = newAmount;

        // --- 相同金额捐款金额的捐款的地址归集到一组 按照捐款从大到小最多保留3组
        // 如果捐款者之前有捐款记录，需要从旧金额组中移除
        if (oldAmount > 0) {
            _removeDonorFromAmountGroup(donor, oldAmount);
        }
        // 将捐款者添加到新金额组中
        _addDonorToAmountGroup(donor, newAmount);

        emit Donation(donor, amount);
        return true;
    }

    /**
     * 内部函数：将捐款者添加到对应金额的分组中
     * 如果该金额是首次出现，将其插入到有序数组中的正确位置
     */
    function _addDonorToAmountGroup(address donor, uint256 amount) internal {
        address[] storage donors = _donorsByAmount[amount];
        // 检查捐款者是否已在该金额组中（理论上不应出现，但为了安全）
        bool alreadyExists = false;
        for (uint i = 0; i < donors.length; i++) {
            if (donors[i] == donor) {
                alreadyExists = true;
                break;
            }
        }
        if (!alreadyExists) {
            donors.push(donor);
        }

        // 如果这个金额是全新的，需要插入到_uniqueAmounts数组中并保持降序
        if (donors.length == 1) { // 只有当该金额组刚创建时长度为1，说明是全新的金额
            _insertAmountInOrder(amount);
        }
    }

    /**
     * 内部函数：从指定金额分组中移除一个捐款者
     * 如果该金额组因此变为空，则从_uniqueAmounts数组中移除该金额
     */
    function _removeDonorFromAmountGroup(address donor, uint256 amount) internal {
        address[] storage donors = _donorsByAmount[amount];
        uint256 length = donors.length;
        for (uint i = 0; i < length; i++) {
            if (donors[i] == donor) {
                // 将最后一个元素移到当前位置，然后弹出最后一个元素
                if (i < length - 1) {
                    donors[i] = donors[length - 1];
                }
                donors.pop();
                break;
            }
        }

        // 如果这个金额组变空了，从有序数组中移除这个金额
        if (donors.length == 0) {
            _removeAmountFromArray(amount);
        }
    }

    /**
     * 内部函数：将金额插入到_uniqueAmounts数组中，保持降序排列
     * 使用插入排序的思想，但只插入一个元素
     */
    function _insertAmountInOrder(uint256 newAmount) internal {
        uint256 i = 0;
        uint256 length = _uniqueAmounts.length;
        
        // 找到第一个比newAmount小的位置
        while (i < length && _uniqueAmounts[i] > newAmount) {
            i++;
        }
        
        // 在位置i插入新金额
        _uniqueAmounts.push(0); // 先扩展数组
        for (uint256 j = length; j > i; j--) {
            _uniqueAmounts[j] = _uniqueAmounts[j - 1];
        }
        _uniqueAmounts[i] = newAmount;
    }

    /**
     * 内部函数：从_uniqueAmounts数组中移除指定的金额
     */
    function _removeAmountFromArray(uint256 amountToRemove) internal {
        uint256 length = _uniqueAmounts.length;
        for (uint256 i = 0; i < length; i++) {
            if (_uniqueAmounts[i] == amountToRemove) {
                // 将最后一个元素移到当前位置，然后弹出最后一个元素
                if (i < length - 1) {
                    _uniqueAmounts[i] = _uniqueAmounts[length - 1];
                }
                _uniqueAmounts.pop();
                break;
            }
        }
    }

    struct DonorInfo {
        address donor;
        uint256 amount;
    }
    //获取top3捐款的地址和金额
    function getDonationTop3() external view returns (DonorInfo[] memory) {
        uint256 totalCount = 0;
        uint256 amountsToProcess = 0;
        
        // 先计算需要返回的前三档金额（可能不足3档）
        uint256 numAmounts = _uniqueAmounts.length;
        amountsToProcess = numAmounts > 3 ? 3 : numAmounts;
        
        // 计算总共有多少个地址需要返回
        for (uint256 i = 0; i < amountsToProcess; i++) {
            totalCount += _donorsByAmount[_uniqueAmounts[i]].length;
        }
        
        // 创建结果数组
        DonorInfo[] memory topDonors = new DonorInfo[](totalCount);
        uint256 currentIndex = 0;
        
        // 填充结果数组
        for (uint256 i = 0; i < amountsToProcess; i++) {
            uint256 amount = _uniqueAmounts[i];
            address[] memory donors = _donorsByAmount[amount];
            
            for (uint256 j = 0; j < donors.length; j++) {
                topDonors[currentIndex] = DonorInfo({
                    donor: donors[j],
                    amount: amount
                });
                currentIndex++;
            }
        }
        
        return topDonors;
    }

    

    //提现
    function withdraw(uint256 amount) external onlyOwner returns (bool) {
        require(amount <= _donationAmount, "Insufficient funds to withdraw");
        payable(_owner).transfer(amount);
        _donationAmount -= amount;
        return true;
    }
    //获取某个地址的捐款
    function getDonation(address from) external view returns (uint256) {
        return _donation[from];
    }
    
    //获取当前总金额
    function getDonationAmount() external view returns (uint256) {
        return _donationAmount;
    }
    //设置捐款结束时间
    function setEndtimestamp(uint256 endtimestamp_)external {
        _endtimestamp=endtimestamp_;
    }

    receive() external payable {}
    fallback() external payable {}
}