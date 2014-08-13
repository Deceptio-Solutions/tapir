#!/bin/bash

export RAILS_ENV=production

# restart thin
echo "killing thin appserver"
#for x  in `ps aux  |grep thin | cut -d ' '  -f 6`;do kill -9 $x;done

kill -9 `cat /home/jcran/tapir/tmp/pids/thin.0.pid`
kill -9 `cat /home/jcran/tapir/tmp/pids/thin.1.pid`
kill -9 `cat /home/jcran/tapir/tmp/pids/thin.2.pid`

#application serveri
echo "starting appserver"
bundle exec thin start -e production -s3 --socket /tmp/thin.sock

# background task processingi
echo "killing background workers"
RAILS_ENV=production rvmsudo bundle exec god terminate
echo "starting background workers"
RAILS_ENV=production rvmsudo bundle exec god -c god_config

echo "done"
