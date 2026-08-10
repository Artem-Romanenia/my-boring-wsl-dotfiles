#!/bin/sh

# Set Session Name
SESSION="main_dev"
SESSIONEXISTS=$(tmux list-sessions | grep $SESSION)

# Only create tmux session if it doesn't already exist
if [ "$SESSIONEXISTS" = "" ]
then
	export MSSQL_SA_PASSWORD="P@ssw0rd!!!"

	tmux new-session -d -s $SESSION

	# Window 1

	tmux rename-window -t 1 'main'
	tmux send-keys -t 'main' 'docker compose -f compose_dev.yaml up mssql'

	# Window 2

	tmux new-window -t $SESSION:2 -n 'aug'
	tmux send-keys -t 'aug' 'watch -n 2 docker container list'

	tmux split-window -v
	tmux send-keys -t 'aug' 'docker image list' Enter

	tmux select-pane -t 1
fi

tmux attach-session -t $SESSION:1

