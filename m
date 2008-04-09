From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 09 Apr 2008 06:59:27 +0000
Subject: Re: [DCCP]: Make queuing policy an attribute of a socket
Message-Id: <20080409065927.GC8092@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > We are always allocating (in dccp_init_sock and dccp_create_openreq_child),
| > so why not make dp->dccps_qpolicy a static member rather than a pointer.
| >
| Then should I keep
| 	void dccp_qpolicy_destroy(struct sock *sk)
| as an empty function or delete it? Later it might be used to call policy 
| specific destructor, but now it wouldn't look very useful...
| -- 
That is a good point. With regard to dccp_qpolicy_init(), the only part
that remains after taking the memory allocation out is the assignment of
the default policy. I think it would be clearer to replace the call (in
dccp_init_sock()) of

	dccp_qpolicy_init(sk);

with
	
	dccp_qpolicy_set_id(sk, DCCP_QPOLICY_DEFAULT);

Then it is clear how the initialisation is done.



The University of Aberdeen is a charity registered in Scotland, No SC013683.

