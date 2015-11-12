#!/bin/bash
set -u

# this will fetch cpu time and io counters
# additionally put a label
function markup() {
  ./ppmon --mode c --quiet --batch --label "$1"
  ./ppmon --mode i --quiet --batch
}


function on_exit() {
  # mark end of test
  markup "END"

  # shut down ceph moniotor
  pkill ppmon
}
trap on_exit EXIT


###################### MAIN ######################

# start ppserver -w 1 on every ceph host

# put right pool here
POOL=rbd


# get rss data every 2 seconds in background
(
  ./ppmon  --quiet --mode m --delay 2&
  sleep 1
)

markup "start"

# here you can re/start ceph
# for every node: service ceph start

markup "wait for health ok"

# this will block
while(ceph health | grep -v HEALTH_OK); do
  echo "waiting for health ok";
  sleep 1;
done;

markup "rados write"
rados -p $POOL bench 60 -b 1024 write  -t 128 --no-cleanup;

markup "rados seq"
rados -p $POOL bench 60 seq -t 128;

markup "rados rand"
rados -p $POOL bench 60 rand -t 128;

markup "rados cleanup"
rados -p $POOL cleanup;

# now script ends and on_exit() function is called to set final mark
