program oneofus.aleo;

struct Player:
    id as address;
    innocent as boolean;
    alive as boolean;
    location as u16;

struct Map:
    creator as address;
    data as field;
    meta as field;
    locations as field;
    tools as field;
    tasks as field;

record game_state:
    owner as address.private;
    player1 as Player.private;
    player2 as Player.private;
    player3 as Player.private;
    player4 as Player.private;
    round as u8.private;
    game_started as boolean.private;
    map as Map.private;

struct Task:
    id as u8;
    completed as boolean;
    sabotaged as boolean;
    location as field;

struct Tool:
    id as u8;
    data as field;
    meta as address;
    location as field;
    found as boolean;
    player as address;
    remaining_use as u8;

struct Proposal:
    proposer as address;
    memo as field;
    killer as address;
    decided as boolean;
    kill as boolean;

record Communication:
    owner as address.private;
    id as field.private;
    info as Proposal.private;

record Vote:
    owner as address.private;
    pid as field.private;


mapping tasks:
	key left as field.public;
	value right as Task.public;


mapping proposals:
	key left as field.public;
	value right as Proposal.public;


mapping votes_count:
	key left as field.public;
	value right as u64.public;


mapping agree_votes:
	key left as field.public;
	value right as u64.public;


mapping disagree_votes:
	key left as field.public;
	value right as u64.public;

function publish_proposal:
    input r0 as Proposal.public;
    assert.eq self.caller r0.proposer;
    hash.bhp256 r0.memo into r1 as field;    cast self.caller r1 r0 into r2 as Communication.record;
    output r2 as Communication.record;

    finalize r1 r0;

finalize publish_proposal:
    input r0 as field.public;
    input r1 as Proposal.public;
    set 0u64 into votes_count[r0];
    set r1 into proposals[r0];


function new_vote:
    input r0 as field.public;
    input r1 as address.public;
    cast r1 r0 into r2 as Vote.record;
    output r2 as Vote.record;

    finalize r0;

finalize new_vote:
    input r0 as field.public;
    get.or_use votes_count[r0] 0u64 into r1;
    add r1 1u64 into r2;
    set r2 into votes_count[r0];


function get_vote:
    input r0 as field.private;

    finalize r0;

finalize get_vote:
    input r0 as field.public;
    get.or_use disagree_votes[r0] 0u64 into r1;
    get.or_use disagree_votes[r0] 0u64 into r2;


function agree:
    input r0 as field.private;

    finalize r0;

finalize agree:
    input r0 as field.public;
    get.or_use agree_votes[r0] 0u64 into r1;
    add r1 1u64 into r2;
    set r2 into agree_votes[r0];


function disagree:
    input r0 as Vote.record;

    finalize r0.pid;

finalize disagree:
    input r0 as field.public;
    get.or_use disagree_votes[r0] 0u64 into r1;
    add r1 1u64 into r2;
    set r2 into disagree_votes[r0];


function new_game_state:
    cast aleo15g9c69urtdhvfml0vjl8px07txmxsy454urhgzk57szmcuttpqgq5cvcdy false true 0u16 into r0 as Player;
    cast aleo13upju26f9xnsxz77rs7cs6hffz8d6hpvuvu3xqwmh7trrh65mqpsz4xrl9 true true 0u16 into r1 as Player;
    cast aleo1ht2a9q0gsd38j0se4t9lsfulxgqrens2vgzgry3pkvs93xrrzu8s892zn7 true true 0u16 into r2 as Player;
    cast aleo1fw4xmr8yv88scg20gmzqn2t7ye22wqk2rq22d2ayq6j952v0n5psw7ztqp true true 0u16 into r3 as Player;
    cast aleo15g9c69urtdhvfml0vjl8px07txmxsy454urhgzk57szmcuttpqgq5cvcdy 0field 0field 0field 0field 0field into r4 as Map;
    cast self.caller r0 r1 r2 r3 0u8 false r4 into r5 as game_state.record;
    output r5 as game_state.record;


function start_game:
    input r0 as game_state.record;
    not r0.game_started into r1;
    assert.eq r1 true;
    cast self.caller r0.player1 r0.player2 r0.player3 r0.player4 1u8 true r0.map into r2 as game_state.record;
    output r2 as game_state.record;


function join_game:
    input r0 as game_state.record;
    input r1 as Player.private;
    cast self.caller r0.player1 r0.player2 r0.player3 r1 1u8 true r0.map into r2 as game_state.record;
    output r2 as game_state.record;


function move_player:
    input r0 as u16.private;
    input r1 as Player.private;
    add r1.location r0 into r2;
    cast r1.id r1.innocent r1.alive r2 into r3 as Player;
    output r3 as Player.private;


function complete_task:
    input r0 as game_state.record;
    input r1 as Task.private;
    input r2 as Player.private;
    input r3 as Map.private;
    cast r1.id true r1.sabotaged r1.location into r4 as Task;
    cast r3.creator r3.data r3.meta r3.locations r3.tools 56165341field into r5 as Map;
    output r5 as Map.private;


function sabotage_task:
    input r0 as game_state.record;
    input r1 as Task.private;
    input r2 as Player.private;
    input r3 as Map.private;
    assert.eq r2.innocent false;
    cast r1.id false true r1.location into r4 as Task;
    cast r3.creator r3.data r3.meta r3.locations r3.tools 56165341field into r5 as Map;
    output r5 as Map.private;


function find_tool:
    input r0 as Tool.private;
    input r1 as Player.private;
    input r2 as Map.private;
    cast r2.creator r2.data r2.meta r2.locations 563465413field r2.tasks into r3 as Map;
    output r3 as Map.private;


function use_tool:
    input r0 as Tool.private;
    input r1 as Player.private;
    input r2 as Map.private;
    assert.eq r0.found true;
    assert.eq r0.player r1.id;
    gt r0.remaining_use 0u8 into r3;
    assert.eq r3 true;
    cast r2.creator r2.data r2.meta r2.locations 34656234413field r2.tasks into r4 as Map;
    output r4 as Map.private;


function resolve_round:
    input r0 as game_state.record;
    cast self.caller r0.player1 r0.player2 r0.player3 r0.player4 1u8 true r0.map into r1 as game_state.record;
    output r1 as game_state.record;


function is_game_over:
