From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Aug 2010 05:23:13 +0000
Subject: [PATCH 4/5] dccp ccid-2: Share TCP's minimum RTO code
Message-Id: <1283145794-5615-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Using a fixed RTO_MIN of 0.2 seconds was found to cause problems for CCID-2
over 802.11g: at least once per session there was a spurious timeout. It
helped to then increase the the value of RTO_MIN over this link.

Since the problem is the same as in TCP, this patch makes the solution from
commit "05bb1fad1cde025a864a90cfeb98dcbefe78a44a"
       "[TCP]: Allow minimum RTO to be configurable via routing metrics."
available to DCCP.

This avoids reinventing the wheel, so that e.g. the following works in the
expected way now also for CCID-2:

> ip route change 10.0.0.2 rto_min 800 dev ath0

Luckily this useful rto_min function was recently moved to net/tcp.h,
which simplifies sharing code originating from TCP.

Documentation also updated (plus minor whitespace fixes).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c            |    5 +++--
 Documentation/networking/dccp.txt |   26 ++++++++++++++++++++------
 2 files changed, 23 insertions(+), 8 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -325,8 +325,9 @@ static void ccid2_rtt_estimator(struct sock *sk, const long mrtt)
 		hc->tx_srtt = m << 3;
 		hc->tx_mdev = m << 1;
 
-		hc->tx_mdev_max = max(TCP_RTO_MIN, hc->tx_mdev);
+		hc->tx_mdev_max = max(hc->tx_mdev, tcp_rto_min(sk));
 		hc->tx_rttvar   = hc->tx_mdev_max;
+
 		hc->tx_rtt_seq  = dccp_sk(sk)->dccps_gss;
 	} else {
 		/* Update scaled SRTT as SRTT += 1/8 * (m - SRTT) */
@@ -367,7 +368,7 @@ static void ccid2_rtt_estimator(struct sock *sk, const long mrtt)
 				hc->tx_rttvar -= (hc->tx_rttvar -
 						  hc->tx_mdev_max) >> 2;
 			hc->tx_rtt_seq  = dccp_sk(sk)->dccps_gss;
-			hc->tx_mdev_max = TCP_RTO_MIN;
+			hc->tx_mdev_max = tcp_rto_min(sk);
 		}
 	}
 
--- a/Documentation/networking/dccp.txt
+++ b/Documentation/networking/dccp.txt
@@ -1,18 +1,20 @@
 DCCP protocol
-======
+====== 
 
 Contents
 ====
-
 - Introduction
 - Missing features
 - Socket options
+- Sysctl variables
+- IOCTLs
+- Other tunables
 - Notes
 
+
 Introduction
 ======
-
 Datagram Congestion Control Protocol (DCCP) is an unreliable, connection
 oriented protocol designed to solve issues present in UDP and TCP, particularly
 for real-time and multimedia (streaming) traffic.
@@ -29,9 +31,9 @@ It has a base protocol and pluggable congestion control IDs (CCIDs).
 DCCP is a Proposed Standard (RFC 2026), and the homepage for DCCP as a protocol
 is at http://www.ietf.org/html.charters/dccp-charter.html
 
+
 Missing features
 ========
-
 The Linux DCCP implementation does not currently support all the features that are
 specified in RFCs 4340...42.
 
@@ -45,7 +47,6 @@ http://linux-net.osdl.org/index.php/DCCP_Testing#Experimental_DCCP_source_tree
 
 Socket options
 =======
-
 DCCP_SOCKOPT_SERVICE sets the service. The specification mandates use of
 service codes (RFC 4340, sec. 8.1.2); if this socket option is not set,
 the socket will fall back to 0 (which means that no meaningful service code
@@ -112,6 +113,7 @@ DCCP_SOCKOPT_CCID_TX_INFO
 On unidirectional connections it is useful to close the unused half-connection
 via shutdown (SHUT_WR or SHUT_RD): this will reduce per-packet processing costs.
 
+
 Sysctl variables
 ========
 Several DCCP default parameters can be managed by the following sysctls
@@ -155,15 +157,27 @@ sync_ratelimit = 125 ms
 	sequence-invalid packets on the same socket (RFC 4340, 7.5.4). The unit
 	of this parameter is milliseconds; a value of 0 disables rate-limiting.
 
+
 IOCTLS
 ===
 FIONREAD
 	Works as in udp(7): returns in the `int' argument pointer the size of
 	the next pending datagram in bytes, or 0 when no datagram is pending.
 
+
+Other tunables
+=======
+Per-route rto_min support
+	CCID-2 supports the RTAX_RTO_MIN per-route setting for the minimum value
+	of the RTO timer. This setting can be modified via the 'rto_min' option
+	of iproute2; for example:
+		> ip route change 10.0.0.0/24   rto_min 250j dev wlan0
+		> ip route add    10.0.0.254/32 rto_min 800j dev wlan0
+		> ip route show dev wlan0
+
+
 Notes
 ==-
 DCCP does not travel through NAT successfully at present on many boxes. This is
 because the checksum covers the pseudo-header as per TCP and UDP. Linux NAT
 support for DCCP has been added.
