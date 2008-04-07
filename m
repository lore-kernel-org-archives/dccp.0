From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 07 Apr 2008 09:32:41 +0000
Subject: Re: [DCCP]: Make queuing policy an attribute of a socket
Message-Id: <47F9EA39.1090703@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker pisze:
> What would happen if sk is _not_ set to the default policy -- is there a
> way of copying the policy from sk to newsk?
> 
Yes, in one of the next patches it is changed to dccp_qpolicy_inherit() 
call.

> We are always allocating (in dccp_init_sock and dccp_create_openreq_child), so why not make
> dp->dccps_qpolicy a static member rather than a pointer.
> 
Right, that should be possible.
-- 
Regards,
Tomasz Grobelny
