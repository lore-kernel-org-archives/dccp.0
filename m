From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 13 Dec 2007 09:37:01 +0000
Subject: Re: [Announce]: Test results with latest CCID3 patch set
Message-Id: <20071213093701.GA10838@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Burak

I have tried to replay your results but can not find anything wrong with the current test kernel.
Please have a look at the results below, I repeated the same experiment on two different testbeds.

Incidentally, these results agree with the values you observed for TCP Reno. It seems that the
setup is not right, I am happy to help debugging this but I don't think that there is a problem
with the test kernel.

Can you please describe your setup - maybe something went wrong.

The first thing to check is whether you are really using the test tree - it is necessary to check
out the `dccp' subtree, if you are on the `master' instead of the `dccp' subtree, then you are
using a vanilla 2.6.24-rc5.  A detailed HowTo is on
         http://www.linux-foundation.org/en/Net:DCCP_Testing#Experimental_DCCP_source_tree
The difference can also easily be told in the Request/Response handshake, the CCIDs are now
fully negotiated; the first value of the ConfirmL/R in the DCCP-Response says which CCIDs are
used (but they are still nonetheless set via net.dccp.default.{rx,tx}_ccid).

With regard to Ian's patches: quite a few of these are earlier patches which are either already in
the kernel or part of the test tree. The test tree in addition fixes several bugs/omissions in the
loss detection / loss computation code, so in a way this means comparing apples with pears - it will
not give you a clear result. What it can help with, and I am keen to investigate that, is to make
sure that the test tree does not trade old bugs for new ones.

Similar results had been posted by Patrick Andrieux, who used TBF+delay and TBF+RED (posted this
summer). I tried similar experiments on the test tree, and they produced sane results; but this
was done earlier and not posted.


1) Two hosts via NetEm router
-----------------------------
All runs for 60 seconds from 1.7 Ghz Pentium M laptop onto 2x700Mhz Pentium-III Xeon
SMP server, connected via 2.4GHz PIV acting as router with TBF script as below.
The laptop had a e1000 interface, the PIV 2x100Mbps via crossover (one e100, one sc92301
cheapo RTL8139 clone), the server had an e100, also connected via crossover.
All kernels were 2.6.24-rc5.

tx_qlen = 5:
 1000kbps -  951 kbps   (loss initially up to 5%, going down to ~0.8% after 10 seconds)
 2000kbps - 1.90 Mbps   (loss initially up to 3%, going down to ~0.6% after circa 5 seconds)
 5000kbps - 4.72 Mbps   (loss initially peaking at 1%, converging to ~0.15% after 10 seconds)
10000kbps - 7.73 Mbps   (loss initially at 1%, quickly going down to ~0.2%)

For comparison, TCP throughput with TBF bottleneck of 10Mbps was 7.95 Mbps.

tx_qlen = 0, same setup:
 1000kbps -  950 kbps   (loss initially up to ~6%, then going down to ~0.8% after 10 seconds)
 2000kbps - 1.91 Mbps   (similar loss pattern)
 5000kbps - 4.75 Mbps   (loss initially up to 1%, then going down to ~0.3% after 2 seconds)
10000kbps - 8.90 Mbps   (loss initially up to 1%, quickly going down to ~0.1% after 1..2 seconds)


2) Two hosts via NetEm bridge
-----------------------------
  Sender:   PIV 2.4GHz with e100 NIC
  Receiver: Pentium D 2.8 Ghz with 3com 3c905 (Typhoon)
  Bridge:   PIV 2.4GHz using e100 and 3c905, using NetEm based on 2.6.18-4

All tests likewise for 60 seconds, detailed analysis of p omitted (likely very similar to the above).

tx_qlen = 5:
 1000kbps -  908 kbps
 2000kbps - 1.93 Mbps
 5000kbps - 4.72 Mbps
10000kbps - 8.68 Mbps

For comparison, TCP (cubic) throughput with TBF bottleneck of 10Mbps was 7.85 Mbps. 

tx_qlen = 0, same setup:
 1000kbps -  951 kbps
 2000kbps - 1.88 Mbps
 5000kbps - 4.75 Mbps
10000kbps - 9.15 Mbps


3) Script I used (with RTT@ms, delay=RTT/2):
-------------------------------------------
#!/bin/sh
#
# tc script for rate-control plus delay
#
# Usage: $0 <RTT in ms> <TBF-rate in kbps>
#
set -e

case "$1" in
  start)
        RTT=${2:?}; rate=${3:?}; delay=$(($RTT / 2))
	echo "Using ${delay}ms one-way delay each and a TBF rate of ${rate} Kbps "
	set -x
        tc qdisc add dev eth0 root handle 1: netem delay ${delay}ms
        tc qdisc add dev eth1 root handle 1: netem delay ${delay}ms
	# rate:   rate of incoming tokens, in bytes
	# buffer: size of the bucket, in bytes
	# limit:  number of bytes that can be queued waiting for tokens to become available
        tc qdisc add dev eth0 parent 1:1 tbf rate ${rate}kbit buffer 10000 limit 30000
        tc qdisc add dev eth1 parent 1:1 tbf rate ${rate}kbit buffer 10000 limit 30000
        ;;
  stop)
        tc qdisc del dev eth0 root
        tc qdisc del dev eth1 root
        ;;
  restart) $0 stop; shift; $0 start $@
  	;;
  show|stat*)
        tc -s qdisc ls dev eth0
        tc -s qdisc ls dev eth1
	;;
  *)    echo "Usage: $0 {start|stop|restart|show} <RTT in ms>  <TBF-rate in kbps>"
  	exit 1;;
esac
