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
	tmux send-keys -t 'main' 'sleep 0.2 && clear' Enter 'docker compose -f compose_dev.yaml up mssql'

	# Window 2

	tmux new-window -t $SESSION:2 -n 'docker'
	tmux send-keys -t 'docker' 'sleep 0.2 && clear' Enter 'watch -n 2 docker container list'

	tmux split-window -v
	tmux send-keys -t 'docker' 'sleep 0.2 && clear' Enter 'docker image list' Enter

	tmux select-pane -t 1

	# Window 3

	tmux new-window -t $SESSION:3 -n 'copilot'
	tmux send-keys -t 'copilot' 'sleep 0.2 && clear' Enter 'copilot'
fi

tmux attach-session -t $SESSION:1

