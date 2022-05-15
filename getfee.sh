#!/bin/bash

# we love debugging <3
# please run with `sh -x getfee.sh`

#sudo apt install jq bc

getblockcount() {
echo $(curl -s --user 'rpcuser:passw0rd' -X POST http://127.0.0.1:8332/ --data-binary '{"jsonrpc":"1.0","id":"0","method":"getblockcount"}' -H 'Content-Type: application/json' | jq -r '.result')
}

getblockhash() {
echo $(curl -s --user 'rpcuser:passw0rd' -X POST http://127.0.0.1:8332/ --data-binary '{"jsonrpc":"1.0","id":"0","method":"getblockhash", "params": [ "'$1'" ] }' -H 'Content-Type: application/json' | jq -r '.result')
}

getcoinbasetxid() {
echo $(curl -s --user 'rpcuser:passw0rd' -X POST http://127.0.0.1:8332/ --data-binary '{"jsonrpc":"1.0","id":"0","method":"getblock", "params": [ "'$1'", '1' ] }' -H 'Content-Type: application/json' | jq -r '.result .tx[0]')
}

getfirstvoutvalue() {
echo $(curl -s --user 'rpcuser:passw0rd' -X POST http://127.0.0.1:8332/ --data-binary '{"jsonrpc":"1.0","id":"0","method":"getrawtransaction", "params": [ "'$1'", true ] }' -H 'Content-Type: application/json' | jq -r '.result .vout[0] .value')
}
#echo $(getfirstvoutvalue $(getcoinbasetxid $(getblockhash $(getblockcount))))

#pass this the block height and it will return the allowed coinbase subsidy
# (50 * ONE_HUNDRED_MILLION) >> (self.block_height // SUBSIDY_HALVING_INTERVAL)
blocksubsidy() {
echo "$((5000000000 >> ($1 / 210000)))"
}

# TODO - pass in parameter to script to change this number - and use 144 if no input
nblocks=144

bcnt=$(getblockcount)
echo "block height: $bcnt"

# getting the latest block hasn't been working??? why the hell not?  So do this
bcnt=$((bcnt -1))

# + 1 error... it loops through nblocks+1 for some reason... need to `man seq` I guess...
byesterday=$(echo "$bcnt + 1 - $nblocks" | bc)

totalfee=0
echo looping $byesterday to $bcnt
for i in $(seq $byesterday $bcnt); do
#echo "$i --> $(getfirstvoutvalue $(getcoinbasetxid $(getblockhash $i)))"
total=$(getfirstvoutvalue $(getcoinbasetxid $(getblockhash $i)))
# illegal number when calculating floats?  Lame... ok... - use bc instead
#total=$((total * 100000000))
#total=$((total - $(blocksubsidy i)))

total=$(echo "$total * 100000000" | bc)
#sub=$(blocksubsidy $i)
fee=$(echo "$total - $(blocksubsidy $i)" | bc)
# make bc truncate because (()) doesn't like that shit
fee=$(echo "$fee / 1" | bc)
totalfee=$((fee + totalfee))

echo "block: $i --> fee: $fee"
done
# bc -l makes it do the float-y math..?? hmm, cool!
echo "total fee over last $nblocks blocks is:" $totalfee

avgfee=$(echo "$totalfee / $nblocks" | bc -l)
# get rid of crazy x.00000000 - OH, find a way to call bc and specify output precision!!!!
avgfee=$(echo "$avgfee / 1" | bc)

echo "average fee over $nblocks blocks is: " $avgfee





# on the shoulders of giants
# https://stackoverflow.com/questions/169511/how-do-i-iterate-over-a-range-of-numbers-defined-by-variables-in-bash

# didn't worky-poo
#for bdx in {$bcnt...$(echo "$bcnt - 144" | bc)}
#for bdx in $(eval echo "{$bcnt...$(echo '$bcnt - 144' | bc)}")
#for bdx in $(eval echo "{$byesterday...$bcnt}")
#for (( c=$byesterday; c<=$bcnt; c++ ))
