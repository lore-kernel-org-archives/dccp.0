From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Jun 2008 09:30:32 +0000
Subject: Re: [PATCH 7/7] dccp: Initialise option area of v4/v6 request
Message-Id: <20080611093032.GC8403@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1213102423-27486-8-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1213102423-27486-8-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| 
| The problem is present in TCP too, look at cookie_v4_check and
| tcp_v4_conn_request, we may get to reqsk_free before we set ->opt if
| security_inet_conn_request() returns non zero.
| 
| This is one case where bugs found on DCCP lead to an audit of the
| similar code in TCP and the fix should be done on the common
| infrastructure.
Thanks a lot, this is a better solution and removes the headache
regarding "why do I need to zero this out first".

Very happy to rebuild tree, which looks better with this change.
