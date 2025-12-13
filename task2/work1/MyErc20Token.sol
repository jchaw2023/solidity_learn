// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC20代币标准接口定义
interface MyERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// 实现ERC20代币合约
contract MyERC20Token is MyERC20 {
    string internal _name;        // 代币名称
    string internal _symbol;      // 代币符号
    uint256 internal _totalSupply; // 总供应量
    address internal _owner;     // 合约所有者
    mapping(address => uint256) private _balances; // 地址到余额的映射
    mapping(address => mapping(address => uint256)) private _allowances; // 代理授权映射

    // 转账事件
    event Transfer(address indexed from, address indexed to, uint256 amount);
    // 授权事件
    event Approval(address indexed from, address indexed to, uint256 amount);

    // 所有者权限修饰器
    modifier Ownerable() {
        require(msg.sender == _owner, "No permission");
        _;
    }

    // 构造函数 - 初始化代币信息并铸造初始供应量
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
        _mint(totalSupply_);
    }

    // 获取代币名称
    function name() public view returns (string memory) {
        return _name;
    }

    // 获取代币符号
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // 获取代币小数位数（标准为18位）
    function decimals() public pure returns (uint256) {
        return 18;
    }

    // 内部铸币函数 - 按照小数位数转换并增加供应量
    function _mint(uint256 amount_) internal {
        require(amount_ > 0, "Amount must be greater than 0");
        uint amount = amount_ * 10 ** decimals();
        _totalSupply += amount;
        _balances[_owner] += amount;
    }

    // 外部铸币函数 - 仅所有者可调用
    function mint(uint256 amount) external Ownerable {
        _mint(amount);
    }

    // 获取总供应量
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // 查询地址余额
    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    // 转账函数
    function transfer(
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(recipient != address(0), "Cannot transfer to the zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[recipient] += amount;
        _balances[msg.sender] -= amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // 查询授权额度
    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // 授权函数
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        require(spender != address(0), "Cannot approve to the zero address");
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // 代理转账函数
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        require(recipient != address(0), "Cannot transfer to the zero address");
        require(_balances[sender] >= amount, "Insufficient balance");
        require(
            _allowances[sender][msg.sender] >= amount,
            "Insufficient allowance"
        );
        _allowances[sender][msg.sender] -= amount;
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // 获取合约所有者地址
    function getOwner() external view returns (address) {
        return _owner;
    }
}