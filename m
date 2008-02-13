From: "Leandro Sales" <leandroal@gmail.com>
Date: Wed, 13 Feb 2008 13:18:56 +0000
Subject: Re: [iperf]: Bug fixes in DCCP support
Message-Id: <5bc4c4570802130518m1077707dmc502604ffa1e7deb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20080211113044.GA1609@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080211113044.GA1609@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2008/2/11, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> I found that iperf still had several bugs, some of these involving the
> DCCP support.
>
> The bugs have been fixed and the updated version of iperf has been uploaded to
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#iperf
>
> A tarball with all changes is on
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/iperf/zip/iperf-2.0.2_DCCP-patched-CBR-continuous.tar.bz2
>
> (NB - test tree also updated today).
>
> Details of changes:
> -------------------
>  * fixed counting bugs when DCCP was used in packet-oriented mode
>    (now the packet count is correct and works across UDP/DCCP);
>
>  * enabled UDP-like reporting of statistics also for DCCP;
>
>  * rewrote the algorithm to compute the inter-packet-gap in CBR mode:
>    - in DCCP it tried to stuff the pipe without accounting for the time
>      it spent, thus producing more packets than specified;
>    - in tests this was observed to cause overflow;
>    - the algorithm now measures the actual inter-packet gap of each packet
>      and compares it to the target; adjusting for each send time;
>    - it is more accurate than the previous implementation, in particular
>      so for DCCP.
>  * replaced the delay_loop(), which was using a spin-loop of constantly
>    calling gettimeofday(), with nanosleep(). While the spinloop worked
>    reasonably in many cases, it sometimes caused unwanted delays of
>    50milliseconds or more (process preempted?); it does not block signals
>    like nanosleep; and nanosleep uses the hrtimers interface internally
>    (/usr/src/davem-2.6/Documentation/hrtimers/hrtimers.txt)
>
>  * separated setting TCP window size and SO_{RCV,SND}BUF settings;
>
>  * completely overhauled the IPv6 support, it is in the order of 359 insertions
>    versus 759 deletions; the -V flag is no longer necessary - iperf can now take
>    any v4/v6 hostname, v4/v6 literal address. This required a minor change for
>    the dual test and the tradeoff test (options -2 and -r): they no longer do a
>    check for the reverse-lookup when the reverse connection comes in, instead
>    the peer address is copied from the connection, which will do in almost any
>    conceivable case (doing a reverse lookup leads to complications since it
>    requires complex case distinctions of v4/v6-mapped-v6/v6 addresses).
>
> * IPv4 multicast support did not work well when the server-bind argument (-B)
>   was used on a host with multiple interfaces. This has now been fixed for both
>   IPv4 and IPv6 multicast using the `-j' `-J' arguments (for join-interface).
>   For example:
>         iperf -s -u -B 224.1.2.3          # works if there is only one interface
>         iperf -s -u -B 224.1.2.3 -j eth1  # wanted to join on that one
>         iperf -s -u -B FF00::c0de -J eth2 # IPv6 multicast, same semantics
>
> Hence if anyone is using iperf for DCCP, using the new version is much encouraged,
> as it will produce more reliable and accurate results.
>
> Still - when encountering any problems with this version of iperf, please do report
> these.

Good news Gerrit, but in details of changes you mentioned this:

* enabled UDP-like reporting of statistics also for DCCP;

But according to my tests, I had this for UDP

------------------------------------------------------------
Server listening on UDP port 5001
Receiving 1470 byte datagrams
UDP datagram buffer size:  105 KByte (default)
------------------------------------------------------------
[  3] local 127.0.0.1 port 5001 connected with 127.0.0.1 port 48341
[  3]  0.0- 1.0 sec   129 KBytes  1.06 Mbits/sec   0.007 ms    0/   90 (0%)
[  3]  1.0- 2.0 sec   128 KBytes  1.05 Mbits/sec   0.006 ms    0/   89 (0%)
(...)

and for DCCP

------------------------------------------------------------
Server listening on DCCP port 5001
NOTE: running in bytestream-mode (maximum speed)
DCCP datagram buffer size:  105 KByte (default)
------------------------------------------------------------
[  4] local 127.0.0.1 port 5001 connected with 127.0.0.1 port 45839
[  4]  0.0- 1.0 sec  56.7 MBytes   476 Mbits/sec
[  4]  1.0- 2.0 sec  57.1 MBytes   479 Mbits/sec
[  4]  2.0- 3.0 sec  57.0 MBytes   478 Mbits/sec
[  4]  3.0- 4.0 sec  56.9 MBytes   477 Mbits/sec


What is different for the previous version of your patches?

Thanks,

Leandro.
