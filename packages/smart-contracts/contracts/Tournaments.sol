//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./lib/SafeERC20.sol";
import "./lib/ReentrancyGuard.sol";
import "./interfaces/IERC721.sol";

/**
 * @notice Tournaments contract
 */
contract Tournaments is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice Reporting oracle address
    address public oracle;

    /// @notice Number of tournaments
    uint256 public numTournaments;

    /// @notice Mapping of tournament ids to tournament details
    mapping(uint256 => Tournament) public tournaments;

    /// @notice Mapping of tournament ids to entry fee
    mapping(uint256 => EntryFee) public entryFees;

    /// @notice Mapping of organizer address -> token address -> total tip amount
    mapping(address => mapping(address => uint256)) public organizerTips;

    /// @notice Mapping of tournament id -> prizes
    mapping(uint256 => mapping(uint8 => Prize[])) public tournamentPrizes;

    /// @notice Mapping of tournament id -> asset address -> asset amount
    mapping(uint256 => mapping(address => uint256)) public tournamentPool;

    /// @notice Mapping of tournament id -> tournament placement -> split % of entry fee pool
    mapping(uint256 => mapping(uint8 => uint16)) public tournamentSplits;

    /// @notice Mapping of tournament id -> address of player -> tournament placement
    mapping(uint256 => mapping(address => uint256)) public tournamentPlacements;

    /// @notice Tournament definition
    struct Tournament {
        uint8 numPrizeWinners; // Number of prize winners for tournament
        uint64 startTime; // Unix timestamp of tournament start time
        uint64 endTime; // Unix timestamp of tournament end time
        uint64 resolutionTime; // Unix timestamp of tournament resolution time
        address organizer; // Tournament organizer
        string tournamentURI; // URI that contains the metadata/information for the tournament
    }

    /// @notice Tournament prize
    struct Prize {
        uint8 placement; // prize placement
        uint8 category; // prize category: 0 = ETH, 1 = ERC20, 2 = NFT
        address asset; // contract address for ERC20 or ERC721, address(0) for ETH
        uint256 amount; // prize amount or in the case of NFT - token id
    }

    /// @notice Entry Fee
    struct EntryFee {
        uint8 category; // fee category: 0 = ETH, 1 = ERC20
        address asset; // fee asset: contract address for ERC20 or address(0) for ETH
        uint256 amount; // fee amount
        uint16 organizerTipPercent; // % of fee that goes to organizer
    }

    /// @notice Only tournament organizer can call
    modifier onlyOrganizer(uint256 tournamentID) {
        require(msg.sender == tournaments[tournamentID].organizer, "only organizer");
        _;
    }

    /// @notice Only oracle can call
    modifier onlyOracle() {
        require(msg.sender == oracle, "only oracle");
        _;
    }

    /// @notice Event emitted when a new tournament is created
    event TournamentCreated(
        uint256 indexed tournamentID, 
        address indexed organizer,
        uint8 numPrizeWinners, 
        uint64 startTime,
        uint64 endTime,
        uint64 resolutionTime,
        string tournamentURI
    );

    /// @notice Event emitted when a user joins a tournament
    event TournamentJoined(uint256 indexed tournamentID, address indexed participant);

    /// @notice Event emitted when a user claims their tournament reward
    event RewardClaimed(uint256 indexed tournamentID, address indexed participant, uint256 placement);

    /**
     * @notice Create new Tournaments contract
     * @param oracleAddress Reporting Oracle contract
     */
    constructor(address oracleAddress) {
        oracle = oracleAddress;
    }

    /**
     * @notice Create new tournament
     * @param organizer Tournament organizer
     * @param startTime Unix timestamp of tournament start time
     * @param endTime  Unix timestamp of tournament end time
     * @param resolutionTime Unix timestamp of tournament resolution time
     * @param tournamentURI URI that contains the metadata/information for the tournament
     * @param splitPcts Percentage that each placement receives out of the total fee pool
     * @param prizes Prizes supplied by the tournament creator
     * @param entryFee Fee for joining the tournament
     */
    function createTournament(
        address organizer,
        uint64 startTime,
        uint64 endTime,
        uint64 resolutionTime,
        string memory tournamentURI,
        uint16[] memory splitPcts,
        Prize[] memory prizes,
        EntryFee memory entryFee
    ) external payable nonReentrant {
        require(entryFee.category == 0 || entryFee.category == 1, "entry fee must be ETH or ERC20");
        uint256 paidAmountRemaining = msg.value;

        tournaments[numTournaments] = Tournament({
            numPrizeWinners: uint8(prizes.length),
            startTime: startTime,
            endTime: endTime,
            resolutionTime: resolutionTime,
            organizer: organizer,
            tournamentURI: tournamentURI
        });

        entryFees[numTournaments] = entryFee;

        for(uint i; i< prizes.length; i++) {
            if(prizes[i].category == 0) {
                require(paidAmountRemaining >= prizes[i].amount, "not enough ETH for prize");
                paidAmountRemaining -= prizes[i].amount;
            }

            if(prizes[i].category == 1) {
                IERC20(prizes[i].asset).safeTransferFrom(msg.sender, address(this), prizes[i].amount);
            }

            if(prizes[i].category == 2) {
                IERC721(prizes[i].asset).transferFrom(msg.sender, address(this), prizes[i].amount);
            }

            tournamentPrizes[numTournaments][prizes[i].placement].push(prizes[i]);
        }

        for(uint i; i< splitPcts.length; i++) {
            tournamentSplits[numTournaments][uint8(i)] = splitPcts[i];
        }

        emit TournamentCreated(numTournaments, organizer, uint8(prizes.length), startTime, endTime, resolutionTime, tournamentURI);
        numTournaments++;
    }

    /**
     * @notice Join tournament specified by tournament ID
     * @param tournamentID Tournament ID
     */
    function joinTournament(
        uint256 tournamentID
    ) external payable nonReentrant {
        Tournament storage tournament = tournaments[tournamentID];
        require(block.timestamp < tournament.startTime, "tournament has already begun");
        EntryFee memory fee = entryFees[tournamentID];
        if(fee.category == 0) {
            require(msg.value >= fee.amount, "not enough ETH for entry");
        }

        if(fee.category == 1) {
            IERC20(fee.asset).safeTransferFrom(msg.sender, address(this), fee.amount);
        }

        uint256 tipAmount = fee.amount * fee.organizerTipPercent / 10_000;
        tournamentPool[tournamentID][fee.asset] = tournamentPool[tournamentID][fee.asset] + fee.amount - tipAmount;
        organizerTips[tournament.organizer][fee.asset] = organizerTips[tournament.organizer][fee.asset] + tipAmount;
        emit TournamentJoined(tournamentID, msg.sender);
    }

    /**
     * @notice Post results for given tournament ID
     * @param tournamentID Tournament ID
     * @param winners Addresses of tournament winners (in order of their tournament placement)
     */
    function postResults(uint256 tournamentID, address[] memory winners) external nonReentrant onlyOracle {
        Tournament storage tournament = tournaments[tournamentID];
        require(block.timestamp > tournament.endTime, "tournament has not yet finished");
        for(uint i; i< winners.length; i++) {
            tournamentPlacements[tournamentID][winners[i]] = i;
        }
    }

    /**
     * @notice Claim rewards for given tournament
     * @param tournamentID Tournament ID
     */
    function claimRewards(uint256 tournamentID) external nonReentrant {
        Tournament storage tournament = tournaments[tournamentID];
        EntryFee memory fee = entryFees[tournamentID];
        require(block.timestamp >= tournament.resolutionTime, "tournament has not yet resolved");
        uint8 placement = uint8(tournamentPlacements[tournamentID][msg.sender]);
        if(placement < tournament.numPrizeWinners) {
            Prize[] memory prizes = tournamentPrizes[tournamentID][placement];
            for(uint i; i< prizes.length; i++) {
                if(prizes[i].category == 0) {
                    require(address(this).balance >= prizes[i].amount, "not enough ETH for prize");
                    (bool success, ) = msg.sender.call{value: prizes[i].amount}("");
                    require(success, "unable to send ETH prize");
                }

                if(prizes[i].category == 1) {
                    IERC20 token = IERC20(prizes[i].asset);
                    require(token.balanceOf(address(this)) >= prizes[i].amount, "not enough tokens for prize");
                    token.safeTransfer(msg.sender, prizes[i].amount);
                }

                if(prizes[i].category == 2) {
                    IERC721 token = IERC721(prizes[i].asset);
                    require(token.ownerOf(prizes[i].amount) >= address(this), "contract does not have desired token");
                    token.transferFrom(address(this), msg.sender, prizes[i].amount);
                }
            }
        }

        uint16 placementPct = tournamentSplits[tournamentID][placement];
        if(fee.amount > 0 && placementPct > 0) {
            uint256 poolAmount = tournamentPool[tournamentID][fee.asset];
            uint256 poolShare = poolAmount * placementPct / 10_000;
            if(fee.category == 0) {
                require(address(this).balance >= poolShare, "not enough ETH in pool");
                (bool success, ) = msg.sender.call{value: poolShare}("");
                require(success, "unable to send ETH pool share");
            }

            if(fee.category == 1) {
                IERC20 token = IERC20(fee.asset);
                require(token.balanceOf(address(this)) >= poolShare, "not enough tokens in pool");
                token.safeTransfer(msg.sender, poolShare);
            }
        }

        emit RewardClaimed(tournamentID, msg.sender, placement);
    }

    /**
     * @notice Claim organizer tips for a given asset
     * @param asset Token contract address, or address(0) for ETH
     */
    function claimTips(address asset) external {
        uint256 owedTips = organizerTips[msg.sender][asset];
        require(owedTips > 0, "no tips available for given organizer and asset");
        if(asset == address(0)) {
            (bool success, ) = msg.sender.call{value: owedTips}("");
            require(success, "unable to send ETH tips");
        } else {
            IERC20 token = IERC20(asset);
            require(token.balanceOf(address(this)) >= owedTips, "not enough tokens in contract");
            token.safeTransfer(msg.sender, owedTips);
        }
    }

}
