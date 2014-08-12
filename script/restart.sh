#!/bin/bash

export RAILS_ENV=production

# restart thin
for x  in `ps aux  |grep thin | cut -d ' '  -f 6`;do kill -9 $x;done

#application server
thin start -e production -s6 --socket /tmp/thin.sock


# background task processing
#bundle exec god -c god_config

