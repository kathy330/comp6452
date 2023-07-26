// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Oracle {
    struct Data {
        uint temperature;
        uint nitrogenContent;
        uint sterilizationTime;
    }

    mapping(address => Data) public data;

    function provide(address processorAddress, uint temperature, uint nitrogenContent, uint sterilizationTime) public {
        data[processorAddress] = Data(temperature, nitrogenContent, sterilizationTime);
    }

    function getData(address processorAddress) public view returns (uint, uint, uint) {
        return (data[processorAddress].temperature, data[processorAddress].nitrogenContent, data[processorAddress].sterilizationTime);
    }
}
