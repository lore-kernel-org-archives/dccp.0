From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 25 Aug 2010 11:42:29 +0000
Subject: Re: dccp test-tree [Patch 1/1] ccid-3: use per-route min-RTO
Message-Id: <20100825114228.GB4570@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="uAKRQypu60I7Lcqm"
List-Id: <dccp.vger.kernel.org>
References: <20100816051936.GD3571@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20100816051936.GD3571@gerrit.erg.abdn.ac.uk>
To: dccp@vger.kernel.org


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Ivo,-
| Acked-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>  for ccid4 subtree
| 
| On Mon, Aug 16, 2010 at 02:19, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
| > This patch relates to the similar one submitted last week for CCID-2.
| >
| > It replaces the hardcoded (Kconfig) value of the minimum RTO value with
| > a reconfigurable, per-route value which falls back to the TCP minimum
| > RTO value.
| >
| > Leando, Ivo, can you please have a look and indicate whether you are ok
| > with this? If yes I would like to also update the CCID-4 tree to make it
| > consistent with the test tree - for this reason the test tree has not yet
| > been updated.
| >
| >>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
| > dccp ccid-3: use per-route RTO or TCP RTO as fallback
| >
Thank you for the (offline) review, I have revised the patch, uploaded the one for CCID-3
at 182be62cc2899ddf7adb0c7654792f7061373a8a of the test tree.

The corresponding (revised) patch for CCID-4 has been integrated into 

    http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=57ebee26dc7125f5cff75f0153ef3cd2bfd03c1d

Please find attached the "inter-diff" of the changes I applied to the CCID-4 subtree.

--uAKRQypu60I7Lcqm
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="ccid4_INTER.diff"

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -65,37 +65,6 @@ config IP_DCCP_CCID3_MEASURE_S_AS_MAX
 	---help---
 	  An experimental method based on tracking the maximum packet size.
 endchoice
-
-config IP_DCCP_CCID3_RTO
-	int "Use higher bound for nofeedback timer"
-	default 100
-	depends on IP_DCCP_CCID3
-	---help---
-	  Use higher lower bound for nofeedback timer expiration.
-
-	  The TFRC nofeedback timer normally expires after the maximum of 4
-	  RTTs and twice the current send interval (RFC 5348, 4.3). On LANs
-	  with a small RTT this can mean a high processing load and reduced
-	  performance, since then the nofeedback timer is triggered very
-	  frequently.
-
-	  This option enables to set a higher lower bound for the nofeedback
-	  value. Values in units of milliseconds can be set here.
-
-	  A value of 0 disables this feature by enforcing the value specified
-	  in RFC 5348. The following values have been suggested as bounds for
-	  experimental use:
-	    * 16-20ms to match the typical multimedia inter-frame interval
-	    * 100ms as a reasonable compromise [default]
-	    * 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
-
-	  The default of 100ms is a compromise between a large value for
-	  efficient DCCP implementations, and a small value to avoid disrupting
-	  the network in times of congestion.
-
-	  The purpose of the nofeedback timer is to slow DCCP down when there
-	  is serious network congestion: experimenting with larger values should
-	  therefore not be performed on WANs.
 endif	# IP_DCCP_CCID3
 
 config IP_DCCP_CCID4
@@ -114,8 +83,7 @@ config IP_DCCP_CCID4
 	  sending rate, possibly with Explicit Congestion Notification (ECN),
 	  while minimizing abrupt rate changes.
 
-	  CCID-4 is based an (expired) Internet-Draft which can be found at:
-	  http://tools.ietf.org/html/draft-ietf-dccp-ccid4
+	  CCID-4 is specified in RFC 5622.
 
 	  If in doubt, say N.
 
@@ -150,13 +118,6 @@ config IP_DCCP_CCID4_MEASURE_S_AS_MAX
 	---help---
 	  An experimental method based on tracking the maximum packet size.
 endchoice
-
-config IP_DCCP_CCID4_RTO
-	int "Use higher bound for nofeedback timer"
-	default 100
-	---help---
-	  This item does for CCID-3 as DCCP_CCID3_RTO does for CCID-3, please
-	  see the help text there.
 endif	# IP_DCCP_CCID4
 
 config IP_DCCP_TFRC_LIB
--- a/net/dccp/ccids/ccid4.c
+++ b/net/dccp/ccids/ccid4.c
@@ -445,12 +445,12 @@ done_computing_x:
 
 	/*
 	 * Update timeout interval for the nofeedback timer.
-	 * We use a configuration option to increase the lower bound.
-	 * This can help avoid triggering the nofeedback timer too
-	 * often ('spinning') on LANs with small RTTs.
+	 * We use the current (per-route) value of the TCP RTO as lower bound
+	 * to slow down rate-halving on networks with small RTTs (loopback,
+	 * running DCCP in a virtual machine, Gbit ethernet, etc).
 	 */
-	hc->tx_t_rto = max_t(u32, 4 * hc->tx_rtt, (CONFIG_IP_DCCP_CCID4_RTO *
-						 (USEC_PER_SEC / 1000)));
+	hc->tx_t_rto = max_t(u32, 4 * hc->tx_rtt,
+				  USEC_PER_SEC/HZ * tcp_rto_min(sk));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)

--uAKRQypu60I7Lcqm--
