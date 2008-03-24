From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 24 Mar 2008 10:27:51 +0000
Subject: Re: packet priorities
Message-Id: <20080324102751.GB10112@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > Agree now with the set/getsockopts, sorry it took me a bit longer to
| > understand. But am still uneasy with the sysctls, since they will
| > apply only to some specific policy.
| >
| Ok, I can remove the sysctls. The important question is: should we keep 
| pregister function pointer? To keep the code simple for now we should 
| probably remove it, right?
| 
Yes that would be good. If the the policy needs initialisation, there is
the init() constructor also.


| Then what should be the sequence to set up socket?
| 1. create socket
| 2. setsockopt policy_id -> does not call any policy specific code
| 3. setsockopt tx_qlen -> calls policy specific setsockopt
| 4. connect() or listen() -> calls policy specific init()
| Am I right?
| 
This looks correct to me. There is one subtle case - policies created
on the listening socket would be inherited by the child socket, due
to the use of sock_copy() called via dccp_create_openreq_child(). If
the policy manipulates private data, then each child socket would
need its own, separate copy.

If it is of help - the same problem came up in the feature negotiation
code, where dccp_feat_finalise_settings() acts in a similar way to init().
