#!/bin/sh
tmux new-session -d -s Drone

tmux new-window -t Drone:1 -n 'Redis Server' 'redis-server'
tmux new-window -t Drone:2 -n 'Resque Worker' 'bundle exec resque work -q plugin -r ../lib/esearchy/drone/workers.rb'
tmux new-window -t Drone:3 -n 'Drone' 'ruby ../bin/esearchy_drone'
tmux select-window -t Drone:3
tmux -2 attach-session -t Drone
