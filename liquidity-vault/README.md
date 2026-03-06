## Foundry

```shell
Using foundry, Build a factory that deploys vaults(using CREATE2) for any erc20 token... i.e a user can deposit a token and a vault is created for that token... users can add the vault liquidity to the vault by depositing that same token to Deployment of the vault mints an NFT whose art is fully onchain sg showng the details about that vault like the token details, amount deposited etc... You must use a mainnet fork for this task...which means you will be using reallife tokens as samples Explain the step as if to a novice, especially.. You must use a mainnet fork for this task (when I don't have funds in mainnet)

```

```
forge build
forge test --fork-url $MAINNET_RPC_URL -vv
```
