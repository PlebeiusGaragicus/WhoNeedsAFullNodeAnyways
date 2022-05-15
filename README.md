# WhoNeedsAFullNodeAnyways
This is my spruned playground

This is also a very much work in progress

Welcome to my work-in-progress repository where I fiddle with gathering data from the bitcoin blockchain without running a full node.

I'm going to be using the spruned repo.  This repo acts as a lightweight node, or node emulator (not sure about terminology) and connects to peers (other bitcoin nodes) and downloads data on request.

I communicate with the running spruned instance via RPC calls and gather whatever data I need.

Experiment 1: calculate the average block fees in the last 24 hours (144 blocks)

This is how I install spruned on a Debian VM using parallels on an M1 macbook

```bash
cd $HOME
sudo apt update
sudo apt-get install libleveldb-dev python3-dev git virtualenv gcc g++ python3-venv --yes

git clone https://github.com/gdassori/spruned.git
cd spruned
python3 -m venv venv
source venv/bin/activate

pip install cython
pip install wheel

pip install -r requirements.txt
python setup.py install

./spruned.py --debug --rpcuser rpcuser --rpcpassword passw0rd --rpcbind 0.0.0.0 --rpcport 8332

```

I'm not sure that spruned needs to be 'installed' ... as I am just running the script and not importing the python module.  Installing spruned gave me a LOT of issues and it took over a day to finally fix.  This old, sad repo needs some love - hasn't been updated in years!

the getfee.sh script needs these installed:
```bash
sudo apt install jq bc
```

Now that spruned is running, I run this in another terminal:
```bash
sh getfee.sh
```

How does getfee.sh calculate the average block fee in the last 24 hours?

1) get current block height
2) loop through the last 144 blocks
3) get a block and get the txid of the first transaction in that block (the coinbase tx)
4) look up the tx by txid and get the value (in bitcoin) that was sent to the miner
5) calculate and subtract the block subsidy from the total amount - what remains is the sum of transaction fees

This method is not perfect and makes several assumptions as well as not being as fast or as 'trustworthy' as using a full archive node.

Can you think of the assumptions being made in this method of calculation?

What about possible issues with the trust-worthiness of the data?
