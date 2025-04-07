// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
address constant usd_eth_dataFeed = 0x694AA1769357215DE4FAC081bf1f309aDC325306; //sepolia network
address constant usd_eth_dataFeed_zksync = 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF;

library PriceConverter {
     
     function getDataFeedInstance() internal pure returns(AggregatorV3Interface){
        AggregatorV3Interface dataFeed = AggregatorV3Interface(
            usd_eth_dataFeed_zksync
        );
        return dataFeed;
     }

     function getChainlinkDataFeedLatestAnswer() internal view returns (int) {
        AggregatorV3Interface dataFeed = getDataFeedInstance();
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer * 1e10;
    }

    function getConversionToUSD(uint amount) internal pure returns(uint){
        uint price = 1423670000000000000000;
        //uint(getChainlinkDataFeedLatestAnswer());
        require(price > 0, "Price not suitable for computation");
        return (amount * price) / 1e18;
    }

    function getVersion() internal view returns(uint256){
        AggregatorV3Interface dataFeed = getDataFeedInstance();

        return dataFeed.version();
    }


}