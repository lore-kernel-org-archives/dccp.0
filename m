From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Apr 2008 09:30:29 +0000
Subject: Re: [DCCP]: Allow changing qpolicy for a socket
Message-Id: <20080407093029.GJ6146@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.50563.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.50563.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| --- a/net/dccp/minisocks.c
| +++ b/net/dccp/minisocks.c
| @@ -142,7 +142,7 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
|  			return NULL;
|  		}
|  		dccp_init_xmit_timers(newsk);
| -		dccp_qpolicy_init(newsk);
| +		dccp_qpolicy_inherit(newsk, sk);
Ah, good. Missed that in the first patch, so the question about copying
from sk to newsk is answered. But why not use dccp_qpolicy_inherit in
the first patch?

| --- a/net/dccp/proto.c
| +++ b/net/dccp/proto.c
| @@ -544,6 +544,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
|  	case DCCP_SOCKOPT_RECV_CSCOV:
|  		err = dccp_setsockopt_cscov(sk, val, true);
|  		break;
| +	case DCCP_SOCKOPT_QPOLICY_ID:
| +		err = dccp_qpolicy_set_id(sk, val);
| +		break;
This allows anytime changes to the policy which can create havoc when you are in the middle
of a connection. I think we should add something like
	if (sk->sk_state != DCCP_CLOSED)
		err = -EISCONN;
	else
		err = dccp_qpolicy_set_id(sk, val);

or add this test to dccp_qpolicy_set_id.		

| --- a/net/dccp/qpolicy.c
| +++ b/net/dccp/qpolicy.c
| @@ -27,6 +27,26 @@ void dccp_qpolicy_init(struct sock *sk)
|  	dp->dccps_qpolicy->qpol_ops = qpolicy_operations[DCCP_QPOLICY_DEFAULT];
|  }
|  
| +int dccp_qpolicy_set_id(struct sock *sk, int id)
| +{
| +	struct dccp_sock *dp = dccp_sk(sk);
| +	if(id >= ARRAY_SIZE(qpolicy_operations))
| +		return -EINVAL;
| +	dp->dccps_qpolicy->qpol_ops = qpolicy_operations[id];
| +	return 0;
| +}
Nit: can you please leave one line between declaration of dccp_sock
and code (or use dccp_sk(sk) directly); and space between "if (id ...".


The University of Aberdeen is a charity registered in Scotland, No SC013683.

