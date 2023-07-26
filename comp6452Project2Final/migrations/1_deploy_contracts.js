const FarmerProcessor = artifacts.require("FarmerProcessor");
const FarmerProcessorDelegate = artifacts.require("FarmerProcessorDelegate");

module.exports = function (deployer) {
  deployer.deploy(FarmerProcessor).then(() => {
    return deployer.deploy(FarmerProcessorDelegate, FarmerProcessor.address);
  });
};
