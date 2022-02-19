const { expect } = require("chai")
const { ethers } = require("hardhat");
const { tournamentsFixture } = require("../fixtures")

describe('Tournaments', () => {
    let tournaments
    let resultsOracle
    let alice
    let bob
    let ZERO_ADDRESS

    beforeEach(async () => {
      const fix = await tournamentsFixture()
      tournaments = fix.tournaments
      resultsOracle = fix.resultsOracle
      deployer = fix.deployer
      alice = fix.alice
      bob = fix.bob
      ZERO_ADDRESS = fix.ZERO_ADDRESS
    })

    context('createTournament', async () => {
      it('allows a valid tournament creation', async () => {
        // await tournaments.createTournament(alice.address)
      })

    })
  })