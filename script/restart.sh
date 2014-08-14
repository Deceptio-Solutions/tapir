#!/bin/bash

TAPIR_ENV=production

# restart thin
echo "killing thin appserver"
for x  in `pgrep -l -f thin| cut -d ' ' -f 1`;do kill -9 $x;done

#application serveri
echo "starting appserver"
RAILS_ENV=$TAPIR_ENV bundle exec thin start -e development -s3 --socket /tmp/thin.sock

# background task processingi
echo "killing background workers"
RAILS_ENV=$TAPIR_ENV rvmsudo bundle exec god terminate
echo "starting background workers"
RAILS_ENV=$TAPIR_ENV rvmsudo bundle exec god -c god_config

echo "done"
