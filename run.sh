#!/bin/bash
# Make sure Leo is installed.
if ! command -v leo &> /dev/null
then
    echo "leo is not installed."
    exit
fi

# 1: Initializing player Account
echo "
STEP 1: Initializing player Account
"
echo "{
  \"program\": \"oneofus.aleo\",
  \"version\": \"0.0.1\",
  \"description\": \"\",
  \"development\": {
      \"private_key\": \"APrivateKey1zkpEYZjzWhJ63rpHBKuWR1hki7GYFDPQQnoR9RvhEneQGCm\",
      \"address\": \"aleo13w87qndak7wl0fjkpnz852s7gan2gpw3qwz0as92spcj032sngqqhnue8d\"
  },
  \"license\":\"MIT\"
}" > program.json

echo "✅ Successfully initialized account."

# 2: Initializing Game
echo "
STEP 2: Initializing Game
"
echo "{
  \"program\": \"oneofus.aleo\",
  \"version\": \"0.0.1\",
  \"description\": \"\",
  \"development\": {
      \"private_key\": \"APrivateKey1zkpEYZjzWhJ63rpHBKuWR1hki7GYFDPQQnoR9RvhEneQGCm\",
      \"address\": \"aleo13w87qndak7wl0fjkpnz852s7gan2gpw3qwz0as92spcj032sngqqhnue8d\"
  },
  \"license\":\"MIT\"
}" > program.json

leo run new_game_state

echo "✅ Successfully initialized Game."

# json need to be stringified otherwise new lines will throw an error while being parsed
leo run start_game "{owner:aleo13w87qndak7wl0fjkpnz852s7gan2gpw3qwz0as92spcj032sngqqhnue8d.private,player1:{id:aleo15g9c69urtdhvfml0vjl8px07txmxsy454urhgzk57szmcuttpqgq5cvcdy.private,innocent:true.private,alive:true.private,location:125u16.private},player2:{id:aleo13upju26f9xnsxz77rs7cs6hffz8d6hpvuvu3xqwmh7trrh65mqpsz4xrl9.private,innocent:true.private,alive:true.private,location:65u16.private},player3:{id:aleo1ht2a9q0gsd38j0se4t9lsfulxgqrens2vgzgry3pkvs93xrrzu8s892zn7.private,innocent:true.private,alive:true.private,location:3u16.private},player4:{id:aleo1fw4xmr8yv88scg20gmzqn2t7ye22wqk2rq22d2ayq6j952v0n5psw7ztqp.private,innocent:true.private,alive:true.private,location:88u16.private},round:0u8.private,game_started:false.private,map:{creator:aleo15g9c69urtdhvfml0vjl8px07txmxsy454urhgzk57szmcuttpqgq5cvcdy.private,data:54638541654field.private,meta: 8643654654564field.private,locations:8654656545351field.private,tools:543656546541field.private,tasks:5646565465field.private},_nonce:3292275464341265224448318132735237115914305398452392872987526646568310776888group.public}"

echo "✅ Successfully started Game."

# dont put comma , at the end json parser errors
leo run publish_proposal "{proposer:aleo13w87qndak7wl0fjkpnz852s7gan2gpw3qwz0as92spcj032sngqqhnue8d,memo:1452374294790018907888397545906607852827800436field,killer:aleo1ht2a9q0gsd38j0se4t9lsfulxgqrens2vgzgry3pkvs93xrrzu8s892zn7,decided:false,kill:false}"
echo "✅ Successfully sent out communication with memo and proposal to vote out suspect"

leo run new_vote 5333835549190198870495537788198251867282074927837960547042452433547967703876field aleo13w87qndak7wl0fjkpnz852s7gan2gpw3qwz0as92spcj032sngqqhnue8d
echo "✅ Successfully created new vote to kick suspect"

leo run agree 5333835549190198870495537788198251867282074927837960547042452433547967703876field
echo "✅ Successfully voted agree to vote player out"

read -p "Press enter to continue"