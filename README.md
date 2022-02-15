
# Dapp Starter Kit
Everything you need to start building decentralized applications on Ethereum.  

Components:
* [Hardhat](https://hardhat.org/)
* [The Graph](https://thegraph.com/)
* [Vue](https://vuejs.org/)

## Recommendations

### WSL for Windows Users
It is recommended that Windows users first [install Windows Subsystem for Linux - WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10). The recommended Linux distribution to use is Ubuntu 20.04.  Learn more about WSL and the benefits it provides via [this short interactive course](https://docs.microsoft.com/en-us/learn/modules/get-started-with-windows-subsystem-for-linux/)


### Visual Studio Code
If you do not already have a preferred text editor that you use for programming, it is recommended that you [install Visual Studio Code](https://code.visualstudio.com/download).  

In addition, you may find the following VS Code plugins useful:
* [solidity](https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity)
* [Vetur](https://marketplace.visualstudio.com/items?itemName=octref.vetur)
* [YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
* [Apollo GraphQL](https://marketplace.visualstudio.com/items?itemName=apollographql.vscode-apollo&ssr=false#overview)

### GitHub
If you do not already have a GitHub account, it is recommended that you [create one](https://github.com/join) and [add an SSH key to your account](https://docs.github.com/en/free-pro-team@latest/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

### MetaMask
[Install MetaMask](https://metamask.io/download.html) in your browser and create an Ethereum address.  It is recommended to create a new account exclusively for testing purposes that will never hold any mainnet balances.

### Rinkeby ETH
Use the [Rinkeby faucet](https://faucet.rinkeby.io/) to populate your testing address with Rinkeby ETH.

### Vue Devtools Extension
[Install the Vue Devtools extension](https://chrome.google.com/webstore/detail/vuejs-devtools/nhdogjmejiglipccpnnnanhbledajbpd) for helpful tools to aid in debugging your frontend code


## Sign up for Accounts
* [Sign up for a free Infura account](https://infura.io/register) and create a new project to get an API key.
* [Sign up for a free Etherscan account](https://etherscan.io/register) and create a new API key.
* [Sign up for a free Coinmarketcap account](https://accounts.coinmarketcap.com/signup) and generate an API key.
* [Sign up for a free Blocknative account](https://explorer.blocknative.com/account) and create one API key for each environment you intend to use (i.e. prod, staging, local, etc.)

## Prerequisites
Make sure you have installed all of the following prerequisites on your development machine:
* Git - [Download & Install Git](https://git-scm.com/downloads). OSX and Linux machines typically have this already installed.
* Node.js - [Download & Install Node.js](https://nodejs.org/en/download/) and the npm package manager. If you encounter any problems, you can also use this [GitHub Gist](https://gist.github.com/isaacs/579814) to install Node.js.
* Yarn - [Download & Install Yarn](https://classic.yarnpkg.com/en/docs/install#mac-stable)

## Project setup
In a terminal window type:
```
git clone git@github.com:chiangmaidapps/dapp-starter-kit.git my-new-dapp
```
```
cd my-new-dapp
```
```
yarn install
```

## Learn More
Documentation:
* [Solidity Docs](https://docs.soliditylang.org/en/v0.7.4/)
* [Ethers Docs](https://docs.ethers.io/v5/)
* [The Graph Docs](https://thegraph.com/docs/introduction)
* [Vue Docs](https://vuejs.org/v2/guide/)
* [Buefy Docs](https://buefy.org/documentation)

Resources:
* [Solidity By Example](https://solidity-by-example.org/0.6/) - Basic smart contract best practices
* [scaffold-eth](https://github.com/austintgriffith/scaffold-eth) - Starter kit based on React with a ton of resources