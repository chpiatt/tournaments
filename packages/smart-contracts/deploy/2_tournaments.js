module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const Oracle = await deployments.get("TournamentResultsOracle")

  log(`2) Tournaments`)
  // Deploy Tournaments contract
  const deployResult = await deploy("Tournaments", {
    from: deployer,
    contract: "Tournaments",
    gas: 4000000,
    args: [Oracle.address],
    skipIfAlreadyDeployed: true
  });

  if (deployResult.newlyDeployed) {
    log(`- ${deployResult.contractName} deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`);
  } else {
    log(`- Deployment skipped, using previous deployment at: ${deployResult.address}`)
  }
};

module.exports.tags = ["2", "Tournaments"]