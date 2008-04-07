From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Apr 2008 09:38:29 +0000
Subject: Re: [DCCP]: Allow applications to change tx_qlen
Message-Id: <20080407093829.GK6146@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.58295.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.58295.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| --- a/net/dccp/proto.c
| +++ b/net/dccp/proto.c
| @@ -547,6 +547,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
|  	case DCCP_SOCKOPT_QPOLICY_ID:
|  		err = dccp_qpolicy_set_id(sk, val);
|  		break;
| +	case DCCP_SOCKOPT_QPOLICY_TXQLEN:
| +		err = dccp_qpolicy_set_txqlen(sk, val);
| +		break;
Not necessary to declare dccp_qpolicy_set_txqlen to return an int (0):
err is initialised with err = 0 above, so can simply write
		dccp_qpolicy_set_txqlen(sk, val);
		break;
or - I can't think of any other place to use this, so  a function may not be needed:

		dccp_sk(sk)->dccps_qpolicy->qpol_txqlen = len;
		break;

| --- a/net/dccp/qpolicy_prio.c
| +++ b/net/dccp/qpolicy_prio.c
| @@ -34,13 +34,14 @@ struct sk_buff *dccp_queue_get_worst(struct sk_buff_head *list)
|  
|  void prio_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_size_t controllen)
|  {
| +	int tx_qlen = dccp_sk(sk)->dccps_qpolicy->qpol_txqlen;
|  	struct dccp_policy_prio *dcp = (struct dccp_policy_prio *)control;
|  	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
|  	SKB_PRIO(dcb)->priority = 127;
|  	if(dcp)
|  		memcpy(SKB_PRIO(dcb), dcp, min(sizeof(struct dccp_policy_prio), controllen));
|  	skb_queue_tail(&sk->sk_write_queue, skb);
| -	if(sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen)
| +	if(sk->sk_write_queue.qlen >= tx_qlen)
This is good - but should keep in mind to deprecate sysctl_dccp_tx_qlen
in a future patch, since it is now "unemployed".

| --- a/net/dccp/qpolicy_simple.c
| +++ b/net/dccp/qpolicy_simple.c
| @@ -20,7 +20,8 @@ void simple_push(struct sock *sk, struct sk_buff *skb, void* control, __kernel_s
|  
|  int simple_full(struct sock *sk)
|  {
| -	return (sysctl_dccp_tx_qlen && (sk->sk_write_queue.qlen >= sysctl_dccp_tx_qlen));
| +	int tx_qlen = dccp_sk(sk)->dccps_qpolicy->qpol_txqlen;
| +	return (tx_qlen && (sk->sk_write_queue.qlen >= tx_qlen));
|  }
Nit: can you please leave one line between declaration and code.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

