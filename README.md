# ceph_monitor
Simple tool in Python to help monitoring ram/cpu/io usage around ceph.

In general:

This python script finds every osd/monitor proces on defined hosts
(using parallel python), and fetch some usefull info by psutil.

Currently you can monitor memory, cpu and io counters.

Data can be displayed in realtime in console:

  PROC         MINOR    MAJOR           RSS  # x 10M
  mds 000    2490469        4      10543104  ###########
  mon 000    2076111    12749     756822016  #########################
  mon 001    1848765    18453     973025280  #########################
  mon 002    1843250    12506     920768512  ##############################
  osd 000     273045      639     626556928  ##################################
  osd 001     233141      448     602361856  #################################
  osd 002     254646      585     575537152  ##############################
  osd 003     251395      499     627011584  ############################

You can switch views by typing i,c,m and then hit enter.

  PROC          read()    read_bytes       write()   write_bytes
  mon 00       7470464         90112        272133     589221888
  mon 01       7472152             0        267940     589238272
  mon 02       5014558      38817792        942471     455593984
  osd 00    6775071796       6508544   11818598367   23701143552
  osd 01    5694510931       2064384   10639996895   21335928832


  PROC     CTX_I  CTX_V    CPU usr     CPU sys
  mds 000      0     11  0010.5600   0032.8500
  mon 000      1     75  0127.6900   0062.6700
  mon 001     21     65  0112.5400   0075.8400
  mon 002      0     77  0070.9800   0041.9000

Data can be gathered in sqlite database and ploted with gnuplot.

Look for details in /readme.txt.

Look for sample gnuplot ouput and test scripts in /examples.
