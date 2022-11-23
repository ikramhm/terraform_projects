This terraform module provisions a EC2 instance (m4.xlarge with additional storage) and uses the geth client to run an ethereum node therein. The sync takes place with the rinkeby testnet. In September 2022, the ethereum protocol moved away from Proof-of-Work to Proof-of-Stake, in an event known as "the Merge". Unfortunately, "the Merge" has rendered this terraform module unusable. For the motivations of this significant change, see https://ethereum.org/en/upgrades/merge/

In the pre-merge world, I had deployed ethereum nodes to testnets, using AWS EC2; however, I did this manually. For the instuction I followed, see: https://sideofburritos.com/blog/how-to-securely-setup-an-ethereum-node/ and https://pawelurbanek.com/ethereum-node-aws

Nevertheless, I find Cardstack's module to be simple and genuis: it provisions an EC2, and runs the geth client as a shell script for the EC2's user-data. Borrowing from this idea, I intend to create a terraform module which deploys a post-merge ethereum node. I intend to use netheremind for the execution layer, and Prysm for the consensus layer. Cardstack has developped the neccesary foundation - all that is required is the shell script for this new Exceution-Consensus layer installation, integration, and execution.

https://docs.nethermind.io/nethermind/first-steps-with-nethermind/running-nethermind-post-merge 
