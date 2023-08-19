// 'oneofus' An Aleo experience.
program oneofus.aleo {

    struct Player {
        id: address,        // the Aleo public address of the player
        innocent: bool,     // true for innocent, false for traitor
        alive: bool,        // true for alive, false for dead
        location: u16,      // location of the player in the map, stored as the cell id in the map, precise location only needed in the UI
    }

    record game_state { 
        owner : address,    // owner of the game is the one who creates a new instance of the game
        player1 : Player,   // this demo is limited to 4 players but we aim to make it configurable in the near future
        player2 : Player,
        player3 : Player,
        player4 : Player,
        round: u8,          // keeps track of rounds, increments from 0
        game_started: bool, // keep track of game status
        map: Map,
    }

    struct Map {            // Maps will be external contracts with tradable NFT ownership
        creator: address,   // current owner of the Map that gets paid from games played in this map
        data: field,        // link to data storage, could be on Aleo or external storage
        meta: field,        // extra storage for keeping track of map version or other tags
        locations: field,   // encoded information of predetermined location of 
        tools: field,       // random distribution of 26 tool throughout the 32x32 grid map, encoded using 
        tasks: field,       // encoed tasks that are available in this map and their status
    }

    struct Task {
        id: u8,             // id of the task type
        completed: bool,    // default at false, turns true once done
        sabotaged: bool,    // true for alive, false for dead
        location: field,    //location on map
    }

    mapping tasks: field => Task; 

    struct Tool {          //Tools are found randomly thought the map and grant player abilities
        id: u8,             //Tool id
        data: field,        //link to data storage, could be on Aleo or external storage
        meta: address,      //extra storage for keeping track of version or other tags
        location: field,    //encoded information of predetermined location of 
        found: bool,        //whether the tool has been found by a player
        player: address,    //player in possetion of the tool if found
        remaining_use: u8,  //remaining uses of the ability, tools that can only be used once start with this value set at 1
    }

    struct Proposal {
        proposer: address,  // player that created proposal
        memo: field,        // encoded message   
        killer: address,    // the suspect that the proposer believes is the traitor
        decided: bool,      // if decision has been taken
        kill: bool,         // decision to kick or kill suspect
    }

    // store prosal in storage
    mapping proposals: field => Proposal; 

    record Communication {
        owner: address,     // player that started this communication
        id: field,          // id of communication
        info: Proposal,     // proposal sent in this communication
    }

    record Vote {           // votes are seperate in their own record to keep them private
        owner: address,     // player that is voting
        pid: field,         // proposal id
    }

    // Count the total votes issued for each communication / proposal to kill
    mapping votes_count: field => u64;
    mapping agree_votes: field => u64;
    mapping disagree_votes: field => u64;

    // publish new proposal. in the future  check for tools/artifacts found, add other abilities in addition to killing
    transition publish_proposal(public info: Proposal) -> Communication {
        // Authenticate proposer.
        assert_eq(self.caller, info.proposer);

        // Generate a new communication id.
        let id: field = BHP256::hash_to_field(info.memo);

        // Return a new record for the proposal.
        return Communication {
            owner: self.caller,
            id,
            info,
        } then finalize(id,info);
    }
    // Create a new entry for this proposal with votes count 0
    finalize publish_proposal(public proposal_id: field, public info: Proposal) {
        Mapping::set(votes_count, proposal_id, 0u64);
        Mapping::set(proposals, proposal_id, info);
    }

    // Create a new vote
    transition new_vote(
        public pid: field,
        public voter: address,
    ) -> Vote {

        return Vote {
            owner: voter,
            pid,
        } then finalize(pid);
    }
    // Create a new vote on a proposal in the "votes" mapping.
    finalize new_vote(public pid: field) {
        let voteObj: u64 = Mapping::get_or_use(votes_count, pid, 0u64);
        Mapping::set(votes_count, pid, voteObj + 1u64);
    }

    transition get_vote(pid: field) {
        return then finalize(pid);
    }
    finalize get_vote(public pid: field) {
        let agree_vote: u64 = Mapping::get_or_use(disagree_votes, pid, 0u64);
        let disagree_vote: u64 = Mapping::get_or_use(disagree_votes, pid, 0u64);
        //let proposals: Proposal = Mapping::get(proposals, pid);
        
    }

    // Vote privately to agree with a proposal.
    transition agree(pid: field) {
        return then finalize(pid);
    }
    finalize agree(public pid: field) {
        // Publicly increment the number of agree votes.
        let agree_vote: u64 = Mapping::get_or_use(agree_votes, pid, 0u64);
        Mapping::set(agree_votes, pid, agree_vote + 1u64);
    }

    // Vote privately to disagree with a proposal.
    transition disagree(voteObj: Vote) {
        return then finalize(voteObj.pid);
    }
    finalize disagree(pid: field) {
        // Publicly increment the number of disagree votes.
        let disagree_vote: u64 = Mapping::get_or_use(disagree_votes, pid, 0u64);
        Mapping::set(disagree_votes, pid, disagree_vote + 1u64);
    }

    
    transition new_game_state() -> game_state {
        return game_state {
            owner: self.caller,
            player1 : Player { id : aleo15g9c69urtdhvfml0vjl8px07txmxsy454urhgzk57szmcuttpqgq5cvcdy , innocent : false, alive : true, location: 0u16 },
            player2 : Player { id : aleo13upju26f9xnsxz77rs7cs6hffz8d6hpvuvu3xqwmh7trrh65mqpsz4xrl9 , innocent : true , alive : true, location: 0u16 },
            player3 : Player { id : aleo1ht2a9q0gsd38j0se4t9lsfulxgqrens2vgzgry3pkvs93xrrzu8s892zn7 , innocent : true , alive : true, location: 0u16 },
            player4 : Player { id : aleo1fw4xmr8yv88scg20gmzqn2t7ye22wqk2rq22d2ayq6j952v0n5psw7ztqp , innocent : true , alive : true, location: 0u16 },
            round: 0u8,
            game_started: false,
            map: Map { 
                creator : aleo15g9c69urtdhvfml0vjl8px07txmxsy454urhgzk57szmcuttpqgq5cvcdy ,
                data: 0field,
                meta: 0field,
                locations: 0field,
                tools: 0field,
                tasks: 0field,
            }
            };
    }

    transition start_game(
        // The record of the board to start. A board can only be started once.
        game: game_state,
    ) -> game_state {
        // Ensure this game hasn't been used to start a game before.
        assert(!game.game_started);
        // at some point we need to assign traitor role randomly, mod 4 to get index
        return game_state {
            owner: self.caller,
            player1 : game.player1,
            player2 : game.player2,
            player3 : game.player3,
            player4 : game.player4,
            round: 1u8,
            game_started: true,
            map : game.map
        };
    }

    // currently in this demo players are fixed and there are's only 4 players, in the future a player joining a game will be assigned to the next open slot
    transition join_game(game: game_state, player: Player) -> game_state {
        return game_state {
            owner: self.caller,
            player1 : game.player1,
            player2 : game.player2,
            player3 : game.player3,
            player4 : player,
            round: 1u8,
            game_started: true,
            map : game.map
        };
    }

    transition move_player(distance: u16, player: Player) -> Player {
        let new_location: u16 = player.location + distance; // this should be replaced proper trigonometry as both x and y components are encoded in location
        return Player { 
            id : player.id , 
            innocent : player.innocent, 
            alive : player.alive   , 
            location: new_location
        };
    }

    transition complete_task(game: game_state, task: Task, player: Player, map: Map) -> Map {
        //assert player location matches map locaiton of the task
        //assert player is one of the player of this game
        let updated_tasks: Task = Task {
                                id: task.id,             
                                completed: true,   
                                sabotaged: task.sabotaged,   
                                location: task.location,   
                            }; //update encoded task status
        //compute field from task object
        return Map { 
                creator : map.creator ,
                data: map.data,
                meta: map.meta,
                locations: map.locations,
                tools: map.tools,
                tasks: 56165341field,
            };
    }
    transition sabotage_task(game: game_state, task: Task, player: Player, map: Map) -> Map {
        //assert player location matches map locaiton of the task
        //assert player is one of the player of this game
        
        assert_eq(player.innocent, false); //assert player role is traitor

        let sabotaged_tasks: Task = Task {
                                id: task.id,             
                                completed: false,   
                                sabotaged: true,   
                                location: task.location,   
                            }; //update encoded task status
        //compute field from task object
        return Map { 
                creator : map.creator ,
                data: map.data,
                meta: map.meta,
                locations: map.locations,
                tools: map.tools,
                tasks: 56165341field,
            };
    }

    transition find_tool(tool: Tool, player: Player, map: Map) -> Map {
        //assert player location found tool at the generated locaiton
        //give too to player
        //update map data
        let upated_tools : field = 563465413field;
        return Map { 
                creator : map.creator ,
                data: map.data,
                meta: map.meta,
                locations: map.locations,
                tools: upated_tools,
                tasks: map.tasks,
            };
    }

    transition use_tool(tool: Tool, player: Player, map: Map) -> Map {

        assert_eq(tool.found, true);
        assert_eq(tool.player, player.id);
        assert(tool.remaining_use > 0u8);

        let upated_tools : field = 34656234413field;
        return Map { 
                creator : map.creator ,
                data: map.data,
                meta: map.meta,
                locations: map.locations,
                tools: upated_tools,
                tasks: map.tasks,
            };
    }


    /*finalize complete_task(task_id: field) {
         let tasks: u64 = Mapping::get(tasks, task_id); // update tasks status
    }*/

     //function to check task complettion
     //check player is at task completed
     //player movement and location
     //players can move 10 units per block max or smth
     //tasks can be generating proofs of Aleo transactions

    // check if agree > dissagree, if equal votes killer kills one player
    transition resolve_round(
        game: game_state,
    ) -> game_state {
        //kill vote out player
        //check for win
        return game_state {
            owner: self.caller,
            player1 : game.player1,
            player2 : game.player2,
            player3 : game.player3,
            player4 : game.player4,
            round: 1u8,
            game_started: true,
            map : game.map
        };
    }

    /*
        Aleo Proof Generation Functions (if decided to be implemented):
        generate_proof(task_id): Generates a proof for the completion of a task.
        verify_proof(proof): Verify the proof generated for a task.
    */

    transition is_game_over() {
        // check if condition for game is over are met
    }
}
