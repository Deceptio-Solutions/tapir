#!/bin/bash

export RAILS_ENV=production

# restart thin
echo "killing thin appserver"
for x  in `ps aux  |grep thin | cut -d ' '  -f 6`;do kill -9 $x;done

#application serveri
echo "starting appserver"
bundle exec thin start -e production -s3 --socket /tmp/thin.sock

# background task processingi
echo "killing background workers"
rvmsudo bundle exec god terminatei
echo "starting background workers"
rvmsudo bundle exec god -c god_config

echo "done"
