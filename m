From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Feb 2008 11:30:44 +0000
Subject: [iperf]: Bug fixes in DCCP support
Message-Id: <20080211113044.GA1609@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I found that iperf still had several bugs, some of these involving the
DCCP support. 

The bugs have been fixed and the updated version of iperf has been uploaded to
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#iperf

A tarball with all changes is on  
http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/zip/iperf-2.0.2_DCCP-patched-CBR-continuous.tar.bz2

(NB - test tree also updated today).

Details of changes:
-------------------
 * fixed counting bugs when DCCP was used in packet-oriented mode
   (now the packet count is correct and works across UDP/DCCP);

 * enabled UDP-like reporting of statistics also for DCCP;

 * rewrote the algorithm to compute the inter-packet-gap in CBR mode:
   - in DCCP it tried to stuff the pipe without accounting for the time
     it spent, thus producing more packets than specified;
   - in tests this was observed to cause overflow;
   - the algorithm now measures the actual inter-packet gap of each packet
     and compares it to the target; adjusting for each send time;
   - it is more accurate than the previous implementation, in particular
     so for DCCP.
 * replaced the delay_loop(), which was using a spin-loop of constantly
   calling gettimeofday(), with nanosleep(). While the spinloop worked
   reasonably in many cases, it sometimes caused unwanted delays of
   50milliseconds or more (process preempted?); it does not block signals
   like nanosleep; and nanosleep uses the hrtimers interface internally
   (/usr/src/davem-2.6/Documentation/hrtimers/hrtimers.txt)

 * separated setting TCP window size and SO_{RCV,SND}BUF settings;

 * completely overhauled the IPv6 support, it is in the order of 359 insertions
   versus 759 deletions; the -V flag is no longer necessary - iperf can now take
   any v4/v6 hostname, v4/v6 literal address. This required a minor change for
   the dual test and the tradeoff test (options -2 and -r): they no longer do a
   check for the reverse-lookup when the reverse connection comes in, instead
   the peer address is copied from the connection, which will do in almost any
   conceivable case (doing a reverse lookup leads to complications since it
   requires complex case distinctions of v4/v6-mapped-v6/v6 addresses).

* IPv4 multicast support did not work well when the server-bind argument (-B)
  was used on a host with multiple interfaces. This has now been fixed for both
  IPv4 and IPv6 multicast using the `-j' `-J' arguments (for join-interface).
  For example:
  	iperf -s -u -B 224.1.2.3	  # works if there is only one interface
	iperf -s -u -B 224.1.2.3 -j eth1  # wanted to join on that one
	iperf -s -u -B FF00::c0de -J eth2 # IPv6 multicast, same semantics

Hence if anyone is using iperf for DCCP, using the new version is much encouraged,
as it will produce more reliable and accurate results.

Still - when encountering any problems with this version of iperf, please do report
these.
