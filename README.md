# HyperSubs (WIP)

Create subscriptions on one chain but subscribe/extend on any chain

### Made possible by:

- [HyperLane](https://www.hyperlane.xyz/)
- [Solady](https://github.com/Vectorized/solady)

#### Issues:

- Messy
- Hard to use?
- Very easy to shoot yourself in the foot (No input checks)
- No factory
- No UI

#### Deployments:

- [Router](https://testnet.snowtrace.io/address/0x3977a463860458754ed0314ba06fd3994571db63)
- [Recipient](https://goerli.etherscan.io/address/0x605ae8c83511ecc4a573bc25fa3aeb701183ea56)
- [Subscription](https://goerli.etherscan.io/address/0x94920b04a3b6d0c8ebc2c1410de51e85105db89e)

#### Set Up:

1. git clone https://github.com/Nemusonaneko/HyperSubs.git
2. forge install
3. Create .env copying .env.example
4. Set up variables in ./script/

   CCTP uses tokens from this [faucet](https://usdcfaucet.com/)
   [Hyperlane addresses](https://docs.hyperlane.xyz/docs/resources/addresses)

5. Deploy router by entering into terminal:

   forge script script/DeployRouter.sol:DeployRouter --rpc-url "${RPC_URL}" --broadcast --verify --etherscan-api-key "${EXPLORER_API_KEY}" -vvvv

6. Repeat the same thing for other script.

#### More Docs:
[Hyperlane](https://docs.hyperlane.xyz/docs/introduction/readme)