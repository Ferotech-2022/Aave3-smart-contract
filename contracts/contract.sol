// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract AAVELending {
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrowings;
    uint256 public totalDeposits;
    uint256 public totalBorrowings;
    
    address public aaveTokenAddress; // Address of theg ERC20 token you want to ggggggggggggggggguse (e.g., DAI)
    address public lendingPoolAddress; // Address of the AAVE Lending Pool
    uint256 public collateralRatio; // Collateral ratio for borrowing (e.g., 150 means 1.5x collateral)
    
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    
    constructor  (address _aaveTokenAddress, address _lendingPoolAddress, uint256 _collateralRatio) {
        aaveTokenAddress = _aaveTokenAddress;
        lendingPoolAddress = _lendingPoolAddress;
        collateralRatio = _collateralRatio;
    } 

    function deposit(uint256 amount) external {
        require(amount > 0, "Deposit amount must be greater than 0");
        
        IERC20(aaveTokenAddress).transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
        totalDeposits += amount;
        
        emit Deposit(msg.sender, amount);
    }
    
    function withdraw (uint256 amount) external {
        require(amount > 0, "Withdraw amount must be greater than 0");
        require(amount <= deposits[msg.sender], "Insufficient deposit balance");
        
        IERC20(aaveTokenAddress).transfer(msg.sender, amount);
        deposits[msg.sender] -= amount;
        totalDeposits -= amount;
        
        emit Withdraw(msg.sender, amount);
    }
    
    function borrow(uint256 amount) external {
        require(amount > 0, "Borrow amount must be greater than 0");
        require(deposits[msg.sender] * collateralRatio >= borrowings[msg.sender] + amount, "Exceeded collateral ratio");
        
        IERC20(aaveTokenAddress).transfer(msg.sender, amount);
        borrowings[msg.sender] += amount;
        totalBorrowings += amount;
        
        emit Borrow(msg.sender, amount);
    }
    
    function repay(uint256 amount) external {
        require(amount > 0, "Repay amount must be greater than 0");
        require(amount <= borrowings[msg.sender], "Insufficient borrowing balance");
        
        IERC20(aaveTokenAddress).approve(lendingPoolAddress, amount);
        IERC20(aaveTokenAddress).transferFrom(msg.sender, address(this), amount);
        borrowings[msg.sender] -= amount;
        totalBorrowings -= amount;
        
        emit Repay(msg.sender, amount);
    }
    
    function getDepositBalance(address user) external view returns (uint256) {
        return deposits[user];
    }
    
    function getBorrowingBalance(address user) external view returns (uint256) {
        return borrowings[user];
    }
}
