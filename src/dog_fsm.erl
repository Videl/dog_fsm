-module(dog_fsm).
-behaviour(gen_fsm).

%% Public API
-export([
	notice/3,
	unexpected/2,
	start/1,
	start_link/1,
	pet/1,
	squirrel/1
	]).

-export([
	init/1,
	handle_event/3,
	handle_sync_event/4,
	handle_info/3,
	code_change/4,
	terminate/3,
	% custom state names
	sitting/2,
	barking/2,
	wagging/2
	]).

-record(state, 
	{name=""}).

notice(#state{name=N}, Str, Args) ->
	io:format("~s: "++Str++"~n", [N|Args]).

pet(Pid) ->
	gen_fsm:send_event(Pid, petted).

squirrel(Pid) ->
	gen_fsm:send_event(Pid, squirrel).

%% Unexpected allows to log unexpected messages
unexpected(Msg, State) ->
	io:format("~p received unknown event ~p while in state ~p~n",
	[self(), Msg, State]).

start(Name) ->
	gen_fsm:start(?MODULE, [Name], []).

start_link(Name) ->
	gen_fsm:start_link(?MODULE, [Name], []).

init(Name) ->
	{ok, sitting, #state{name=Name}}.

sitting(squirrel, S=#state{}) ->
	notice(S, "WORF! SAW SQUIRREL OMG!", []),
	{next_state, barking, S};
sitting(Event, Data) ->
	unexpected(Event, sitting),
	{next_state, sitting, Data}.

barking(squirrel, S=#state{}) ->
	notice(S, "WORF! ANOTHER SQUIRREL OMG!", []),
	{next_state, barking, S};
barking(petted, S=#state{}) ->
	notice(S, "RAWwwrr...Moarrrr...", []),
	notice(S, "**WAGS** **WAGS**", []),
	{next_state, wagging, S};
barking(Event, Data) ->
	unexpected(Event, barking),
	{next_state, barking, Data}.

wagging(petted, S=#state{}) ->
	notice(S, "*Sits*", []),
	{next_state, sitting, S};
wagging(Event, Data) ->
	unexpected(Event, wagging),
	{next_state, wagging, Data}.

handle_event(Event, StateName, Data) ->
	unexpected(Event, StateName),
	{next_state, StateName, Data}.

handle_info(Info, StateName, Data) ->
	unexpected(Info, StateName),
	{next_state, StateName, Data}.

code_change(_OldVsn, StateName, Data, _Extra) ->
	{ok, StateName, Data}.

%% Note: DO NOT reply to unexpected calls. Let the call-maker crash!
handle_sync_event(Event, _From, StateName, Data) ->
	unexpected(Event, StateName),
	{next_state, StateName, Data}.
 
%% Transaction completed.
terminate(normal, ready, S=#state{}) ->
	notice(S, "FSM leaving.", []);
	terminate(_Reason, _StateName, _StateData) ->
	ok.
