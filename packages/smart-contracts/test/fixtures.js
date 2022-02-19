const { deployments } = require("hardhat");

const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000"

const tournamentsFixture = deployments.createFixture(async ({ethers}) => {
    const accounts = await ethers.getSigners();
    const deployer = accounts[0]
    const alice = accounts[1]
    const bob = accounts[2]
    const TournamentResultsOracleFactory = await ethers.getContractFactory("TournamentResultsOracle");
    const TournamentResultsOracle = await TournamentResultsOracleFactory.deploy();
    const TournamentsFactory = await ethers.getContractFactory("Tournaments");
    const Tournaments = await TournamentsFactory.deploy(TournamentResultsOracle.address);
    return {
        tournaments: Tournaments,
        resultsOracle: TournamentResultsOracle,
        deployer: deployer,
        alice: alice,
        bob: bob,
        ZERO_ADDRESS: ZERO_ADDRESS
    };
})

module.exports.tournamentsFixture = tournamentsFixture;