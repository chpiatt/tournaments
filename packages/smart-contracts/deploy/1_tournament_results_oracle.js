module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  log(`1) TournamentResultsOracle`)
  // Deploy TournamentResultsOracle contract
  const deployResult = await deploy("TournamentResultsOracle", {
    from: deployer,
    contract: "TournamentResultsOracle",
    gas: 4000000,
    skipIfAlreadyDeployed: true
  });

  if (deployResult.newlyDeployed) {
    log(`- ${deployResult.contractName} deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`);
  } else {
    log(`- Deployment skipped, using previous deployment at: ${deployResult.address}`)
  }
};

module.exports.tags = ["1", "TournamentResultsOracle"]