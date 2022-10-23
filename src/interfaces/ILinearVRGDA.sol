// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct LinearVRGDAInfo {
    uint256 startTime;
    int256 targetPrice;
    int256 priceDecayPercent;
    int256 perTimeUnit;
}
