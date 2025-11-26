// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {

    struct VotedCount {
       bool exists;
       uint count;
    }
    // 候选人得票记录
    mapping(string => VotedCount) public votingCountMap;

    // 投票人记录
    mapping(address => bool) public votingRecord;

    // 候选人列表
    string[] public votedNames;

    // 投票人地址列表
    address[] public votingAddrs;

    /**
     * @dev 允许用户投票给某个候选人
     * @param name 候选人名称
     */
    function vote(string calldata name) public {
        address currentAddr = msg.sender; // 投票人地址
        require(!votingRecord[currentAddr], "Error: Double voting!");
        votingRecord[currentAddr] = true;
        votingAddrs.push(currentAddr);
        if(!votingCountMap[name].exists){
            VotedCount memory vr=VotedCount({ exists:true,count:1});
            votingCountMap[name]=vr;
            votedNames.push(name);
        }else{
            votingCountMap[name].count+=1;
        }
    }

    /**
     * @dev 获取某个候选人的得票数
     * @param name 候选人名称
     * @return 候选人的得票数
     */
    function getVotes(string calldata name) public view returns (uint) {
        VotedCount storage votedCount= votingCountMap[name];
        return votedCount.count;
    }

    /**
     * @dev 重置所有投票数据
     */
    function resetVotes() public {
        uint namesLength = votedNames.length;
        uint addrsLength = votingAddrs.length;

        // 清空候选人得票记录
        for (uint i = 0; i < namesLength; i++) {
            delete votingCountMap[votedNames[i]];
        }

        // 清空投票人记录
        for (uint i = 0; i < addrsLength; i++) {
            delete votingRecord[votingAddrs[i]];
        }

        // 清空候选人列表
        delete votedNames;
    
      
        // 清空投票人地址列表
        delete votingAddrs;
    }
}