From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 09:50:39 +0000
Subject: Re: [PATCH] DCCP: Initialize ireq6->pktopts before used it
Message-Id: <20080610095039.GA8582@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <484E42BE.9020408@cn.fujitsu.com>
In-Reply-To: <484E42BE.9020408@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> I think I should add dccp_v6_reqsk_init() do to the init work since  
> dccp_reqsk_init may be fail too.
>
I think this is not necessary, it can be done like this


	req = inet6_reqsk_alloc(&dccp6_request_sock_ops);
	if (req = NULL)
		goto drop;

	ireq6 = inet6_rsk(req);
	ireq6->pktopts = NULL;

	if (dccp_reqsk_init(req, dccp_sk(sk), skb))
		goto drop_and_free;

This is since dccp_reqsk_init() only initialises the inet_sk and dccp_sk
parts, and does not do IPv6-specific initialisation.

Irrespective of the oops, this is an error and will be fixed in the test
tree today. 

With regard to the oops, the log pointed to the dccp_v6_reqsk_destructor
and so it would make sense, since the pktopts was not initialised to NULL 
and since kfree_skb() calls skb->destructor().

As before, thanks a lot for testing this code and for reporting this.

Gerrit
