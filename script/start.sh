#!/bin/bash

export RAILS_ENV=production

# background task processing
bundle exec god -c god_config

#application server
bundle exec thin start -e production -s6 --socket /tmp/thin.sock

