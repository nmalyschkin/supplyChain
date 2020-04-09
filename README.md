# Simple SupplyChain

## The Smart Contract

The contract is divided into two parts: access control and base.
I didn't use the ownable part as the ownerID was part of the item state and provided all the ownership control I needed.

Access control is fairly easy, addresses get assigned roles by mapping the address to an enum, that represents the role.

Items have a well defined linear life cycle (state):

```
{} -> Harvested -> Processed -> Packed -> ForSale -> Sold -> Shipped -> Received -> Purchase -> ()
```

## Deployed

The contract is deployed on ropsten:
https://ropsten.etherscan.io/address/0x08d6b71ec53e8e5e96e1d37dd0dc130004586150

## IPFS

I did not use IPFS.
