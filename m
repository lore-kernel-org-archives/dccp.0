From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 22 Nov 2007 10:29:55 +0000
Subject: Re: Test tree patch inventory - update
Message-Id: <20071122102955.GA8937@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071120201041.GA24995@ghostprotocols.net>
In-Reply-To: <20071120201041.GA24995@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo,

| > 	[DCCP]: Basic support for passive-close
| 
| What happens if we receive a second CloseReq or a second Close packet or
| if the server performed an active close?
| 
Just to say I am still working on this. First, thanks a lot for pointing
out the bug. This forced me to look again at this patch and ... ecce,
there is another bug: PASSIVE_1/2 may only be entered from OPEN/PARTOPEN, 
the code allowed to enter these states from other states, too. This is
clearly wrong. 
Will send the revised patch once I am clearer what is going on, but this
may not be today.

Gerrit
