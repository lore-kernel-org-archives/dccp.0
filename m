From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Apr 2008 08:47:08 +0000
Subject: Re: [DCCP]: Make queuing policy an attribute of a socket
Message-Id: <20080407084708.GG6146@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| --- a/net/dccp/minisocks.c
| +++ b/net/dccp/minisocks.c
| @@ -23,6 +23,7 @@
|  #include "ccid.h"
|  #include "dccp.h"
|  #include "feat.h"
| +#include "qpolicy.h"
|  
|  struct inet_timewait_death_row dccp_death_row = {
|  	.sysctl_max_tw_buckets = NR_FILE * 2,
| @@ -141,6 +142,7 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
|  			return NULL;
|  		}
|  		dccp_init_xmit_timers(newsk);
| +		dccp_qpolicy_init(newsk);
|  
What would happen if sk is _not_ set to the default policy -- is there a
way of copying the policy from sk to newsk?

| --- a/include/linux/dccp.h
| +++ b/include/linux/dccp.h
| @@ -425,6 +427,7 @@ static inline int dccp_list_has_service(const struct dccp_service_list *sl,
|  }
|  
|  struct dccp_ackvec;
| +struct dccp_qpolicy;
|  
|  /**
|   * struct dccp_sock - DCCP socket state
| @@ -508,6 +511,7 @@ struct dccp_sock {
|  	__u8				dccps_sync_scheduled:1;
|  	struct tasklet_struct		dccps_xmitlet;
|  	struct timer_list		dccps_xmit_timer;
| +	struct dccp_qpolicy		*dccps_qpolicy;
|  };
|  

| --- a/net/dccp/qpolicy.c
| +++ b/net/dccp/qpolicy.c
| @@ -18,22 +18,39 @@ struct dccp_qpolicy_operations* qpolicy_operations[] |  	&simple_policy_operations,
|  };
|  
| +void dccp_qpolicy_init(struct sock *sk)
| +{
| +	struct dccp_sock *dp = dccp_sk(sk);
| +	dp->dccps_qpolicy = kmalloc(sizeof(struct dccp_qpolicy), GFP_KERNEL);
| +	dp->dccps_qpolicy->qpol_ops = qpolicy_operations[DCCP_QPOLICY_DEFAULT];
| +}
| +
| +void dccp_qpolicy_destroy(struct sock *sk)
| +{
| +	struct dccp_sock *dp = dccp_sk(sk);
| +	kfree(dp->dccps_qpolicy);
| +}
| +
We are always allocating (in dccp_init_sock and dccp_create_openreq_child), so why not make
dp->dccps_qpolicy a static member rather than a pointer.



The University of Aberdeen is a charity registered in Scotland, No SC013683.

