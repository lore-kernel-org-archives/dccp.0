From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 May 2008 12:06:51 +0000
Subject: Re: [PATCH 1/1] [DCCP][QPOLICY]: Make information about qpolicies
Message-Id: <20080521120651.GA24590@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
List-Id: <dccp.vger.kernel.org>
References: <20080517155916.34622BD22@poczta.oswiecenia.net>
In-Reply-To: <20080517155916.34622BD22@poczta.oswiecenia.net>
To: dccp@vger.kernel.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Tomasz,

| Since packets with invalid cmsg parameters can be rejected by kernel there
| is a need to allow applications to access information on available policies
| and their respective cmsg parameters at runtime. This patch simplifies
| maintaining compatibility between userspace applications and DCCP code.
| 
The difference to querying supported CCIDs is that
 * CCIDs are all defined per RFC documents, and that
 * different combinations of CCIDs are possible due to the Kconfig options.

As far as I understand your patch, querying here has a different role -
ensuring compatibilities between kernel versions.

I think it might be too early for that:
 * it takes quite a long while until patches propagate through to 
   mainline (more than half a year), so that there is the time to
   come up with a single, well-tested interface;
 * at this stage it would be better to have documentation (man pages,
   web pages, sample application code etc.) to allow people to use 
   the interface - few will want to discover the interface by grepping
   through source code.

DCCP is full of half-finished things. I would much prefer to keep this
as simple as at all possible, to have time/room to fix the missing parts
(such as no ECN support) in DCCP.

As a possible suggestion, I came up with a minimalistic variant of 
querying the interface - only 7 lines, including documentation.

This is attached and it works by exploiting that
 * policy IDs are just numbers;
 * so that we could use the highest supported ID instead of an array;
 * parameters are tied to the individual policy, so that a second
   query (about which parameters are supported) is not necessary.
   
I have put this idea as a suggestion into the `qpolicy' subtree at
	git://eden-feed.erg.abdn.ac.uk/dccp_exp

A trivial test program using this interface can be downloaded from
http://www.erg.abdn.ac.uk/users/gerrit/dccp/query_ids.tar.gz

- Gerrit

--lrZ03NoBR/3+SXJZ
Content-Type: text/x-diff; charset=us-ascii
Content-Description: Combination of querying-available-policies patches.
Content-Disposition: attachment; filename="combined.diff"

This is a smaller diff, combined from the two patches currently in
the qpolicy subtree.
--
 Documentation/networking/dccp.txt |    3 +++
 include/linux/dccp.h              |    1 +
 net/dccp/proto.c                  |    3 +++
 3 files changed, 7 insertions(+)

--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -45,6 +45,9 @@ http://linux-net.osdl.org/index.php/DCCP
 
 Socket options
 ==============
+DCCP_SOCKOPT_QPOLICY_AVAILABLE returns the highest supported policy number. The
+policy IDs start with 0 (default policy) and are consecutively numbered.
+
 DCCP_SOCKOPT_QPOLICY_ID sets the dequeuing policy for outgoing packets. It takes
 a policy ID as argument and can only be set before the connection (i.e. changes
 during an established connection are not supported). Currently, two policies are
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -223,6 +223,7 @@ enum dccp_packet_dequeueing_policy {
 #define DCCP_SOCKOPT_RX_CCID		15
 #define DCCP_SOCKOPT_QPOLICY_ID		16
 #define DCCP_SOCKOPT_QPOLICY_TXQLEN	17
+#define DCCP_SOCKOPT_QPOLICY_AVAILABLE	18
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -666,6 +666,9 @@ static int do_dccp_getsockopt(struct soc
 	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
 		val = dp->dccps_tx_qlen;
 		break;
+	case DCCP_SOCKOPT_QPOLICY_AVAILABLE:
+		val = DCCPQ_POLICY_MAX - 1;
+		break;
 	case 128 ... 191:
 		return ccid_hc_rx_getsockopt(dp->dccps_hc_rx_ccid, sk, optname,
 					     len, (u32 __user *)optval, optlen);

--lrZ03NoBR/3+SXJZ--
