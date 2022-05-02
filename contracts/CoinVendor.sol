// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


// create an interface for ERC20 Tokens to Transfer.
interface IERC20 {
        function balanceOf(address account) external view returns (uint256);
        function transfer(address to, uint256 amount) external returns (bool);
        function approve(address spender, uint256 amount) external returns (bool);
    }

// Creaste A Interface for swapping Tokens
interface IUNIPERI {
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

// Create a Interface for getting current price action.
interface IPRICEORACLE {
    function consult (address _token, uint256 _amountIn) external returns (uint TwaPrice);
    
}
contract CoinVendor {
    IERC20 public USDC;
    IERC20 public WBTC;
    IERC20 public CHAINLINK;
    IPRICEORACLE public POUSDC;
    IPRICEORACLE public POWBTC;
    IPRICEORACLE public POCHAINLINK;
    IUNIPERI public SWAP;
    address public OWNER;
    address AUSDC;
    address AWBTC;
    address ACHAINLINK;
    uint256 public FEE;
    
    constructor(address _USDCADDY, 
    address _WBTC, address _CHAINLINK, uint256 _fee)
    {
        AUSDC = _USDCADDY;
        AWBTC = _WBTC;
        ACHAINLINK = _CHAINLINK;
        USDC = IERC20(AUSDC);
        WBTC = IERC20(AWBTC);
        CHAINLINK = IERC20(ACHAINLINK);
        OWNER = msg.sender;
        FEE = _fee;

    }
 
    //Create a Vend Function
    function vendUSDC() external payable {
        require(msg.value > 0, "Please Insert Coin");
        require(USDC.balanceOf(address(this)) >= msg.value, "Insufficient Funds" );
        USDC.transfer(msg.sender, POUSDC.consult(AUSDC, msg.value) - FEE );
        
    }
    function vendWBTC() external payable {
        require(msg.value > 0, "Please Insert Coin");
        require(WBTC.balanceOf(address(this)) >= msg.value, "Insufficient Funds");
        WBTC.transfer(msg.sender, POWBTC.consult(AWBTC, msg.value) - FEE);
    }
    function vendCHAIN() external payable {
        require(msg.value > 0, "Please Insert Coin");
        require(CHAINLINK.balanceOf(address(this)) >= 0, "Insufficient Funds");
        CHAINLINK.transfer(msg.sender, POCHAINLINK.consult(ACHAINLINK, msg.value) - FEE );     
    }
    // Create a Function to replenish coins.

    function replenishSupplies() public payable {
        address[] memory path = new address[](2);
        path[0] = AUSDC;
        uint deadline = block.number + 15;
        SWAP.swapExactETHForTokens(POUSDC.consult(AUSDC, msg.value / 3), path, address(this), deadline);
        path[0] = AWBTC;
        SWAP.swapExactETHForTokens(POWBTC.consult(AWBTC, msg.value / 3), path, address(this), deadline);
        path[0] = ACHAINLINK;
        SWAP.swapExactETHForTokens(POCHAINLINK.consult(ACHAINLINK, msg.value / 3), path, address(this), deadline);

    }
}
