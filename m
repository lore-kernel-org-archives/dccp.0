From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 10 Dec 2007 15:40:08 +0000
Subject: [Announce]: Test results with latest CCID3 patch set
Message-Id: <20071210154008.GA16839@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

As promised, here are some test results using the latest (2.6.25-backported)
version of the test tree.

These are sanity checks and by no means "statistically significant". For
that it would necessary to run more tests, take averages and calculate
standard deviation / error bars.

Longer test runs (> 1/3 Min) would also be good.

Please therefore feel encouraged to run similar tests against this; on
possibly different pieces of hardware.

All runs were for 20 seconds. The figures in square brackets are the
theoretical values using the throughput equation from RFC 3448, 3.1, which
ignores IP/DCCP header sizes.


I) First run: laptop to double-CPU server via NetEm router
----------------------------------------------------------
This run was done before the latest revision of patches today, but
already including the patch set as per Friday last week.
Setup for these tests:
	* client: Pentium M 1.7 GHz laptop
	* server: 2 x Pentium III 700 MHz SMP server
	* router: 2.4 GHz PIV desktop with 2.6.24 NetEm

RTT 40ms, loss 1%
	* DCCPv6, s20:        3.3  Mbps   [3.3 Mbps]
	*         s%6:         658  kbps   [602 kbps]
	*         s2:           63  kbps   [ 75 kbps]
	* DCCPv4, s40:        3.5  Mbps   [3.4 Mbps]
	*         s%6:         638  kbps   [602 kbps]
	*         s2:           73  kbps   [ 75 kbps]

RTT 150ms, loss 1%
	* DCCPv6, s20:         826 kbps   [891 kbps]
	*         s%6:          120 kbps   [161 kbps]
	*         s2:            18 kbps   [ 20 kbps]
	* DCCPv4, s40:         714 kbps   [904 kbps]
	*         s%6:          230 kbps   [161 kbps]
	*         s2:            20 kbps   [ 20 kbps]

RTT 150ms, loss 10%
	* DCCPv6, s20:        130  kbps   [132 kbps]
	*         s%6:          23  kbps   [ 24 kbps]
	*         s2:           3.8 kbps   [  3 kbps]
	* DCCPv4, s40:        221  kbps   [134 kbps]
	*         s%6:          25  kbps   [ 24 kbps]
	*         s2:            3  kbps   [  3 kbps]



II) Second run: desktop-to-desktop via NetEm bridge
---------------------------------------------------
This run was done with the latest revision of patches today.
Setup for these tests:
	* client: 2.4 GHz PIV desktop
	* server: 2.8 GHz Pentium dual-core desktop
	* bridge: 2.4 GHz PIV desktop with 2.6.18-4 NetEm

RTT 40ms, loss 1%
	* DCCPv6, s20:        3.07 Mbps   [3.3 Mbps]
	*         s%6:          644 kbps   [602 kbps]
	*         s2:            63 kbps   [ 75 kbps]
	* DCCPv4, s40:        3.26 Mbps   [3.4 Mbps]
	*         s%6:          600 kbps   [602 kbps]
	*         s2:            67 kbps   [ 75 kbps]

RTT 150ms, loss 1%
	* DCCPv6, s20:         756 kbps   [891 kbps]
	*         s%6:          148 kbps   [161 kbps]
	*         s2:            16 kbps   [ 20 kbps]
	* DCCPv4, s40:         947 kbps   [904 kbps]
	*         s%6:          131 kbps   [161 kbps]
	*         s2:            23 kbps   [ 20 kbps]

RTT 150ms, loss 10%
	* DCCPv6, s20:         117 kbps   [132 kbps]
	*         s%6:           28 kbps   [ 24 kbps]
	*         s2:           3.6 kbps   [  3 kbps]
	* DCCPv4, s40:         187 kbps   [134 kbps]
	*         s%6:           50 kbps   [ 24 kbps]
	*         s2:             4 kbps   [  3 kbps]


I think this encouraging and asks for more challenging tests.
