// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import '@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol';
import '@uniswap/v2-periphery/contracts/libraries/UniswapV2Library.sol';
import '@uniswap/solidity-lib/contracts/libraries/FixedPoint.sol';


// Interact with the  uniswap Router => Pool to get current amount of token1 and token 2. 
// get the block time
// get new price and add it to old cumulative price and then divide by timeblock (function update)
// create a new variable that will allow you to hold fractions. (function consult)
// Create Interface for Price Orace, create 3 Price Oracle objects for MinOutPrice

contract  uniswapTwapOracle {
    using FixedPoint for *;
    uint public constant PERIOD = 10;

    IUniswapV2Pair public immutable pair;
    address public immutable token0;
    address public immutable token1;

    uint public cumToke0PLast;
    uint public cumToke1PLast;
    uint32 public blockTimeLast;

    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;

    constructor ( address _factory, address _token0, address _token1)  public {
        pair = IUniswapV2Pair(UniswapV2Library.pairFor(_factory, _token0, _token1));
        token0 = pair.token0();
        token1 = pair.token1();
        cumToke0PLast = pair. cumToke0PLast;
        cumToke1PLast = pair.cumToke1PLast;
        (, , blockTimeLast) = pair.getReserves();
    }

function update () public {
    ( uint price0Cumulative,  uint price1Cumulative, uint32 blocktime)  = UniswapV2OracleLibrary.currentCumulativePrice(address(pair));
    uint timeElapsed = blocktime - blockTimeLast;
    price0Average = FixedPoint.uq112x112(uint224( (price0Cumulative - cumToke0PLast) / timeElapsed));
    price1Average = FixedPoint.uq112x112(uint224( (price1Cumulative - cumToke1PLast) / timeElapsed));
    cumToke0PLast = price0Cumulative;
    cumToke1PLast = price1Cumulative;
    blockTimeLast = blocktime;


}

function consult (address _token, uint256 _amountIn) external returns (uint TwaPrice) {
        update();
        require (_token == token0, "invalid token");
            TwaPrice = price0Average.mul(_amountIn).decode144();
        
}


}
}
