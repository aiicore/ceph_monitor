# ceph_monitor
Simple tool in Python to help monitoring ram/cpu/io usage around ceph.

###############################################################################
                     MONITOR CEPH WITH PYTHON REMOTELY
###############################################################################

  1. How it works?
  2. Required packages
  3. Installation
  4. Usage & exmaples
    4.1 Memory mode
    4.2 IO mode
    4.3 CPU mode
    4.4 Command line options
  5. Log data to sqlite
  6. Plot data with gnuplot
  7. New features
  8. Performance impact
  

###############################################################################
  1. How it works?
###############################################################################

  Tool relies on Parallel Python http://www.parallelpython.com "PP" in short.

  PP is python a module which can run functions defined on client, remotely
  on any node in the PP cluster. Functions can have parameters, and results
  are sent back to client node.

  PP is solution mostly used in clustering scenarios, like this:

                                 |> node1
  Client > one2many connection >-|> node2
                                 |> node3
                                 |> ....

  Client don't know on which node submited function is executing.


  In this scenario, I'm using different approach, to get more control on
  scheduling functions on specified node:


           |> one2one connection > - > node1
  Client >-|> one2one connection > - > node2
           |> one2one connection > - > node3
           |> one2one connection > - > ....

  
  Client exactly know on which node function is execued.


###############################################################################
  2. Required packages
###############################################################################

  "python-pp" contanins Parallel Python libraries and bindings, should be avail
  in standard repo of your Linux distro.

  From node perspective: psutil.
  From client perspective: pp, time, sys, select, ConfigParser, os, argparse
  sqlite3, string (maketrans).
 
  Checkout psutil version! There was a change in name of the methods, this code
  works with:
  - CentOs 6.6
  - Parallel Python Network Server (pp-1.5.7)
  - psutil 0.6.1
  
###############################################################################
  3. Installation
###############################################################################

  For CentOs 6.6:

  yum install python-pp

  You should install it on client and every node in your cluster.
  
###############################################################################
  4. Usage & exmaples
###############################################################################

  On every node in your cluster, you must start parallel python server process.
  Most usable way is to run it on screen/tmux terminal multiplexer, so it'll
  be easy to check/interrupt it.

  ppserver has some additional options:

    -h                 : this help message
    -d                 : debug
    -a                 : enable auto-discovery service
    -r                 : restart worker process after each task completion
    -n proto           : protocol number for pickle module
    -c path            : path to config file
    -i interface       : interface to listen
    -b broadcast       : broadcast address for auto-discovery service
    -p port            : port to listen
    -w nworkers        : number of workers to start
    -s secret          : secret for authentication
    -t seconds         : timeout to exit if no connections with clients exist

  If your cluster is in small secured network, you don't need to specify
  secret key, but remember, that whithout it, any other client can connect and
  execute any function with parents permissions (e.g. root)

  This version doesn't support auth, but it's easy to add one so feel free to
  do this :)

  For this solution, I use small workload, so I could define only 1 woker
  thread. Default is as many as your cpu logical cores.

  a) Start servers

    node1 > ppserver -w 1
    node2 > ppserver -w 1
    node3 > ppserver -w 1
    node4 > ppserver -w 1

  b) Setup configuration file

     client > cat ppmon.conf

      [zones]
      # define osd numbers here, add them to zone/group/whatever
      slow_drives = 0-10
      fast_drives = 11-16
      other_drives = 17-40

      [connections]
      # here you have to define nodes on which ppserver is running
      nodes = host1 host2 host3 host4 host5

      [main]
      # show statistics for zones
      show_stats_for = slow_drives other_drives

      # monitor this processes
      processes = ceph-mon ceph-osd ceph-mds

      # path to sql db schema file
      dbschema = dbschema.sql

      # path to the database file
      dbfile = ppmon.db

  c) Start monitor from shell

    client > ./ppmon.py

  #############################################################################
    4.1 Memory mode
  #############################################################################
 
    If you're in another mode, swich to memory mode by typing into console:
      m
    followed by Enter key.

  ----------------------------------------------------------------------------

    Default view is "Memory" which presents information like:

      PROC         MINOR    MAJOR           RSS  # x 10M
      mds 000    2490469        4      10543104  ###########
      mon 000    2076111    12749     756822016  #########################
      mon 001    1848765    18453     973025280  #########################
      mon 002    1843250    12506     920768512  ##############################
      osd 000     273045      639     626556928  ##################################
      osd 001     233141      448     602361856  #################################
      osd 002     254646      585     575537152  ##############################
      osd 003     251395      499     627011584  ############################

      MINOR - Minor memory page faults
      MAJOR - Major memory page faults

      RSS   - Memory Resident Set Size
      # x 10M - RSS represented as hash sign, each one is 10 megabytes

 
  #############################################################################
    4.2 IO mode
  #############################################################################

    If you're in another mode, swich to memory mode by typing into console:
      i
    followed by Enter key.

  ----------------------------------------------------------------------------

    In this mode you can watch IO counters from OSDs and monitors:

      PROC          read()    read_bytes       write()   write_bytes
      mon 00       7470464         90112        272133     589221888
      mon 01       7472152             0        267940     589238272
      mon 02       5014558      38817792        942471     455593984
      osd 00    6775071796       6508544   11818598367   23701143552
      osd 01    5694510931       2064384   10639996895   21335928832


    read()      - calls to system read() function
    read_bytes  - actual data read

    write()     - as above for writes
    write_bytes - as above for writes


    Remember, that when files are cached in linux memory, you will see that
    number of reads() is increasing, but read_bytes are the same. Drop linux
    cache and redo your test, then you will see how data is read.

    More explanation about those factors, can be found in man proc.


  #############################################################################
    4.3 CPU mode
  #############################################################################

    If you're in another mode, swich to memory mode by typing into console:
      c
    followed by Enter key.

  ----------------------------------------------------------------------------

    In this mode you can watch CPU system/user time consumed by process and
    context switch count.

      PROC     CTX_I  CTX_V    CPU usr     CPU sys
      mds 000      0     11  0010.5600   0032.8500
      mon 000      1     75  0127.6900   0062.6700
      mon 001     21     65  0112.5400   0075.8400
      mon 002      0     77  0070.9800   0041.9000

    CTX_I - cpu involuntary context switches
    CTX_V - cpu voluntary context switches  

  #############################################################################
    4.4 Command line options
  #############################################################################


    Most of the command line options are static, except '--zone'. Choices for
    this switch are fetch from you config file.

      usage: ppmon [-h] [--mode {m,i,c}]                                   
                   [--zone {slow_drives,other_drives,fast_drives}] [--nodb]
                   [--batch] [--quiet] [--delay DELAY] [--label LABEL]     
                                                                           
      optional arguments:                                                  
        -h, --help            show this help message and exit              
        --mode {m,i,c}        m:Memory, i:IO counter c:CPU time and context
        --zone {slow_drives,other_drives,fast_drives}                      
                              zone filter (defined in config file)         
        --nodb                disable logging to database                  
        --batch               one shot                                     
        --quiet               don't print on console                       
        --delay DELAY         refresh delay in seconds                     
        --label LABEL         add label to header (for sqlite)             


    When monitor my cluster I do somehing like this:
   
    # get memory statistics every 3 seconds 
    ./ppmon --quiet --mode m --delay 3

    # get io counters every 10 seconds 
    ./ppmon --quiet --mode i --delay 10

    # run once to fetch cpu counters (they are increacing in time), so
    # there is no need to track them at realtime
    ./ppmon --quiet --mode c --batch --label "Ceph staring"

    -- wiait for health ok ---

    ./ppmon --quiet --mode c --batch --label "Ceph started"

    -- wait a while then kill all ppmon's --

    # plote charts using gnuplot
    ./plote ppmon.db "2015-11-06 08:48:00" "2015-11-06 09:00:00"


###############################################################################
  5. Log data to sqlite
###############################################################################

  If you don't pass --nodb option, by default data is collected into sqlite
  database.

  Data is organized in standard way, there is a header with timestamp and label,
  and cpu/mem/io data are attached to it.

  Schema:

    CREATE TABLE IF NOT EXISTS header
      id        INTEGER PRIMARY KEY,
      mode      TEXT,
      timestamp INTEGER,
      label     TEXT
    );

    CREATE TABLE IF NOT EXISTS c(
      header_id   INTEGER,
      key         TEXT,
      ctx_i       INTEGER,
      ctx_v       INTEGER,
      cpu_usr     FLOAT,
      cpu_sys FLOAT
    );

    CREATE TABLE IF NOT EXISTS m(
      header_id   INTEGER,
      key         TEXT,
      min_f       INTEGER,
      maj_f       INTEGER,
      rss         INTEGER
    );

    CREATE TABLE IF NOT EXISTS i(
      header_id INTEGER,
      key       TEXT,
      io_rd     INTEGER,
      io_rb     INTEGER,
      io_wr     INTEGER,
    );


###############################################################################
  6. Plot data with gnuplot
###############################################################################

  ./plote is a script in bash, who runs gnuplot inside and generates graphs
  directly from sqlite database.

  Graphs are saved as png files.


###############################################################################
  7. New features
###############################################################################

  This tool should be able to run any code at node side, so please feel free
  to modify this tool and add new fatures. For example you could manipulate
  ionice by psutil from client, only on specified osd zone.


###############################################################################
  8. Performance impact
###############################################################################
  
  ppserver spawns as many ppworker processes as your logical cpu core count is.

  You could limit this to one, by starting ppserver with "-w 1" parameter.

  Average CPU usage for ppworker during 1 second refresh is about 3%i (on my
  setup). It could be less, by changing rss_mon function to watch only OSD/MON
  pids, but now is more universal - it searches OSD and MON processes
  dynamically so, you could see how they're dis-/appearing during cluster
  restart.
