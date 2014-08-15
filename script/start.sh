#!/bin/bash

export RAILS_ENV=production

#application server
bundle exec thin start -e production -s3 --socket /tmp/thin.sock

# background task processing
rvmsudo bundle exec god -c god_config

