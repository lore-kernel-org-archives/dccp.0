From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 20 Jul 2006 18:12:28 +0000
Subject: DCCP & CCID2: 200ms RTT, 1Gbit/s?  No problem...
Message-Id: <20060720181228.GA3391@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

well, sortof... =P

Hardware:
====Intel e1000 Gbit PCIe card.
Intel Xeon 3GHz.
Two of these, connected with a wire.

Software:
====* Dave miller's tree of about a couple of months ago.
* The two patch sets [11, 3] that I sent to the DCCP ml.

Practice:
====sorlinux ~ # sysctl net.core.wmem_default
net.core.wmem_default = 150000000
sorlinux ~ # tc qdisc show dev eth4
qdisc netem 8001: limit 36000 delay 200.0ms
sorlinux ~ # 

sorlinux dccp # iperf-2.0.2/src/iperf -X DCCP -i1 -l 1400 -c 1.2.3.5 -t 30
------------------------------------------------------------
Client connecting to 1.2.3.5, DCCP port 5001
TCP window size:   143 MByte (default)
------------------------------------------------------------
[  5] local 1.2.3.4 port 49044 connected with 1.2.3.5 port 5001
[  5]  0.0- 1.0 sec  15.0 KBytes    123 Kbits/sec
[  5]  1.0- 2.0 sec    111 KBytes    907 Kbits/sec
[  5]  2.0- 3.0 sec    844 KBytes  6.91 Mbits/sec
[  5]  3.0- 4.0 sec  6.25 MBytes  52.5 Mbits/sec
[  5]  4.0- 5.0 sec  41.6 MBytes    349 Mbits/sec
[  5]  5.0- 6.0 sec    112 MBytes    944 Mbits/sec
[  5]  6.0- 7.0 sec    114 MBytes    955 Mbits/sec
[  5]  7.0- 8.0 sec    114 MBytes    958 Mbits/sec
[  5]  8.0- 9.0 sec    114 MBytes    957 Mbits/sec
[  5]  9.0-10.0 sec    113 MBytes    946 Mbits/sec
[  5] 10.0-11.0 sec    113 MBytes    951 Mbits/sec
[  5] 11.0-12.0 sec    112 MBytes    944 Mbits/sec
[  5] 12.0-13.0 sec    112 MBytes    939 Mbits/sec
[  5] 13.0-14.0 sec    112 MBytes    938 Mbits/sec
[  5] 14.0-15.0 sec    112 MBytes    942 Mbits/sec
[  5] 15.0-16.0 sec    111 MBytes    932 Mbits/sec
[  5] 16.0-17.0 sec    109 MBytes    915 Mbits/sec
[  5] 17.0-18.0 sec    110 MBytes    919 Mbits/sec
[  5] 18.0-19.0 sec    109 MBytes    916 Mbits/sec
[  5] 19.0-20.0 sec    111 MBytes    928 Mbits/sec
[  5] 20.0-21.0 sec    111 MBytes    933 Mbits/sec
[  5] 21.0-22.0 sec    114 MBytes    952 Mbits/sec
[  5] 22.0-23.0 sec    114 MBytes    954 Mbits/sec
[  5] 23.0-24.0 sec    113 MBytes    950 Mbits/sec
[  5] 24.0-25.0 sec    112 MBytes    941 Mbits/sec
[  5] 25.0-26.0 sec    113 MBytes    949 Mbits/sec
[  5] 26.0-27.0 sec    113 MBytes    949 Mbits/sec
[  5] 27.0-28.0 sec    112 MBytes    940 Mbits/sec
[  5] 28.0-29.0 sec    113 MBytes    946 Mbits/sec
[  5]  0.0-30.0 sec  2.79 GBytes    798 Mbits/sec
sorlinux dccp #

Do I get a cookie?
