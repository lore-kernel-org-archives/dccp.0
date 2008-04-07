From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 07 Apr 2008 10:01:35 +0000
Subject: Re: [DCCP]: Allow applications to change tx_qlen
Message-Id: <47F9F0FF.9000703@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.58295.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.58295.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker pisze:
> | --- a/net/dccp/proto.c
> | +++ b/net/dccp/proto.c
> | @@ -547,6 +547,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
> |  	case DCCP_SOCKOPT_QPOLICY_ID:
> |  		err = dccp_qpolicy_set_id(sk, val);
> |  		break;
> | +	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
> | +		err = dccp_qpolicy_set_txqlen(sk, val);
> | +		break;
> Not necessary to declare dccp_qpolicy_set_txqlen to return an int (0):
> err is initialised with err = 0 above, so can simply write
> 		dccp_qpolicy_set_txqlen(sk, val);
> 		break;
> or - I can't think of any other place to use this, so  a function may not be needed:
> 
> 		dccp_sk(sk)->dccps_qpolicy->qpol_txqlen = len;
> 		break;
> 
That's what I originally did. But then I thought that:
1. This way is prettier and more consistent. Which is of course very 
subjective.
2. Later we might want to return an error when changing tx_qlen for an 
already initialized policy wouldn't make sense or would require 
additional code complexity. This is exactly the case you mentioned in 
our previous discussion: choosing algorithms based on queue length.

> | --- a/net/dccp/qpolicy_prio.c
> | +++ b/net/dccp/qpolicy_prio.c
> | @@ -34,13 +34,14 @@ struct sk_buff *dccp_queue_get_worst(struct sk_buff_head *list)
> |  
> |  void prio_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen)
> |  {
> | +	int tx_qlen = dccp_sk(sk)->dccps_qpolicy->qpol_txqlen;
> |  	struct dccp_policy_prio *dcp = (struct dccp_policy_prio *)control;
> |  	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
> |  	SKB_PRIO(dcb)->priority = 127;
> |  	if(dcp)
> |  		memcpy(SKB_PRIO(dcb), dcp, min(sizeof(struct dccp_policy_prio), controllen));
> |  	skb_queue_tail(&sk->sk_write_queue, skb);
> | -	if(sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)
> | +	if(sk->sk_write_queue.qlen >= tx_qlen)
> This is good - but should keep in mind to deprecate sysctl_dccp_tx_qlen
> in a future patch, since it is now "unemployed".
> 
No, sysctl_dccp_tx_qlen still acts as a default:
diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 7315bf0..d774a57 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -25,6 +25,7 @@ void dccp_qpolicy_init(struct sock *sk)
  	struct dccp_sock *dp = dccp_sk(sk);
  	dp->dccps_qpolicy = kmalloc(sizeof(struct dccp_qpolicy), GFP_KERNEL);
  	dp->dccps_qpolicy->qpol_ops = qpolicy_operations[DCCP_QPOLICY_DEFAULT];
+	dp->dccps_qpolicy->qpol_txqlen = sysctl_dccp_tx_qlen;
  }
-- 
Regrads,
Tomasz Grobelny
