From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 05 Oct 2007 09:43:04 +0000
Subject: [Announce]: Test tree updated
Message-Id: <200710051043.05455@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

All submitted feature-negotiation patches have been put into the test tree, after scrubbing
them for superfluous whitespace.



Ian, there was overlap with your second patch, since one of the test tree patches also removed
the LISTEN blocks. Below is an rcsdiff of your second patch (I keep all patches under revision 
control as well): a `-+' means that a previous addition was now removed, a `--' means that a
previous removal is now removed (as with all removals in ccid3.c), single +/- mean that the
context has changed. 

---------------> rcsdiff -u of Ian's second patch <--------------------------------

--- ./2.diff	2007/10/02 10:43:40	1.4
+++ ./2.diff	2007/10/05 09:27:05
@@ -27,29 +26,7 @@
  };
  
  extern int ccid_register(struct ccid_operations *ccid_ops);
-@@ -171,6 +176,11 @@ static inline int ccid_hc_rx_getsockopt(
- 					u32 __user *optval, int __user *optlen)
- {
- 	int rc = -ENOPROTOOPT;
-+
-+	/* Listen socks don't have a private CCID block */
-+	if (sk->sk_state = DCCP_LISTEN)
-+		return -EINVAL;
-+
- 	if (ccid->ccid_ops->ccid_hc_rx_getsockopt != NULL)
- 		rc = ccid->ccid_ops->ccid_hc_rx_getsockopt(sk, optname, len,
- 						 optval, optlen);
-@@ -182,9 +192,44 @@ static inline int ccid_hc_tx_getsockopt(
- 					u32 __user *optval, int __user *optlen)
- {
- 	int rc = -ENOPROTOOPT;
-+
-+	/* Listen socks don't have a private CCID block */
-+	if (sk->sk_state = DCCP_LISTEN)
-+		return -EINVAL;
-+
- 	if (ccid->ccid_ops->ccid_hc_tx_getsockopt != NULL)
- 		rc = ccid->ccid_ops->ccid_hc_tx_getsockopt(sk, optname, len,
+@@ -197,4 +202,24 @@ static inline int ccid_hc_tx_getsockopt(
  						 optval, optlen);
  	return rc;
  }
@@ -58,11 +35,6 @@
 +				const int optname, int val, int optlen)
 +{
 +	int rc = -ENOPROTOOPT;
-+
-+	/* Listen socks don't have a private CCID block */
-+	if (sk->sk_state = DCCP_LISTEN)
-+		return -EINVAL;
-+
 +	if (ccid->ccid_ops->ccid_hc_rx_setsockopt != NULL)
 +		rc = ccid->ccid_ops->ccid_hc_rx_setsockopt(sk, optname,
 +						 val, optlen);
@@ -73,46 +45,17 @@
 +				const int optname, int val, int optlen)
 +{
 +	int rc = -ENOPROTOOPT;
-+
-+	/* Listen socks don't have a private CCID block */
-+	if (sk->sk_state = DCCP_LISTEN)
-+		return -EINVAL;
-+
 +	if (ccid->ccid_ops->ccid_hc_tx_setsockopt != NULL)
 +		rc = ccid->ccid_ops->ccid_hc_tx_setsockopt(sk, optname,
 +						 val, optlen);
 +	return rc;
 +}
  #endif /* _CCID_H */
---- a/net/dccp/ccids/ccid3.c
-+++ b/net/dccp/ccids/ccid3.c
-@@ -612,10 +612,6 @@ static int ccid3_hc_tx_getsockopt(struct
- 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
- 	const void *val;
- 
--	/* Listen socks doesn't have a private CCID block */
--	if (sk->sk_state = DCCP_LISTEN)
--		return -EINVAL;
--
- 	switch (optname) {
- 	case DCCP_SOCKOPT_CCID_TX_INFO:
- 		if (len < sizeof(hctx->ccid3hctx_tfrc))
-@@ -904,10 +900,6 @@ static int ccid3_hc_rx_getsockopt(struct
- 	const void *val;
- 	struct tfrc_rx_info rx_info;
- 
--	/* Listen socks don't have a private CCID block */
--	if (sk->sk_state = DCCP_LISTEN)
--		return -EINVAL;
--
- 	switch (optname) {
- 	case DCCP_SOCKOPT_CCID_RX_INFO:
- 		if (len < sizeof(rx_info))
 --- a/net/dccp/proto.c
 +++ b/net/dccp/proto.c
-@@ -525,6 +525,14 @@ static int do_dccp_setsockopt(struct soc
- 			 * ChangeL(MinimumChecksumCoverage, val) */
- 		}
+@@ -538,6 +538,14 @@ static int do_dccp_setsockopt(struct soc
+ 	case DCCP_SOCKOPT_RECV_CSCOV:
+ 		err = dccp_setsockopt_cscov(sk, val, true);
  		break;
 +	case 128 ... 191:
 +		err = ccid_hc_rx_setsockopt(dp->dccps_hc_rx_ccid, sk, optname,
