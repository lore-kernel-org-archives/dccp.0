From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 09 Aug 2009 19:48:37 +0000
Subject: [PATCH 0/10]: DCCPv4/6 support for ECN/ECT(0)
Message-Id: <1249847327-6792-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This extends DCCP with ECN/ECT(0) capability, requesting review and comments.

In particular,
 * following RFC 2474 and RFC 3168, the set takes an AF-independent approach,
 * the kernel still takes an AF-dependent approach (inet->tos, inet6->tclass),
   so it would be good to have input what the general trend is,
 * some of the patches touch on general issues and hence need discussion.


Patch  #1: Adds the ECN bits into the CB, for processing by DCCP and its CCIDs.
Patch  #2: Adds a sysctl to for dccpv4/6 ECN support (similar to tcp_ecn sysctl).
Patch  #3: Adds feature-negotiation handler for DCCP ECN support.
Patch  #4: Is a hack to add ECN support. It is _not_ meant for consideration. I'd
           appreciate any suggestions of doing this better. Currently there is no
           full IPv6 ECN support: only TCPv4 uses ECN, SCTPv6 uses a workaround.
           If you are reviewing this, please also check the next one.
Patch  #5: Disables userspace modification of ECN bits via IP_TOS/IPV6_TCLASS,
           since this will corrupt the internal ECN values. It is needed by this
           approach for DCCP, but also by SCTPv6, since it is otherwise possible
           to modify the ECN bits of np->tclass in userspace.
Patch  #6: Extends the TFRC loss interval code of DCCP to support ECN.
Patch  #7: Complements patch #6 by adding support for ECN-CE congestion events.
Patch  #8: Adds Ack Vector ECN support to CCID-2.
Patch  #9: AF-independent modification of DCCP ECN bits (compare #5).
Patch #10: AF-independent reading of DCCP-ECN bits; complements #9.

All patches (apart from #5) have been tested for approximately one year and
are now integrated into the DCCP test tree available at

	git://eden-feed.erg.abdn.ac.uk/dccp_exp  [subtree 'dccp']
	
	http://eden-feed.erg.abdn.ac.uk	         [web view]
	http://eden-feed.erg.abdn.ac.uk/latest-dccp-test-tree.tar.bz2

Before doing this, I compile-tested the tree again and ran a quick iperf test to
ensure that ECT(0) is now working (DCCPv6 tested via ::1 loopback).

