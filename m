From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 22 Nov 2007 16:09:19 +0000
Subject: Re: [RFC]: Withdrawal of passive-close patches
Message-Id: <20071122160919.GA19979@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071122153843.GA13762@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071122153843.GA13762@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| >If you or anyone on the list can create a condition which will 
| >lead to "application received data but didn't have a chance to 
| >read it", I'd like to hear about it.
| 
| ... snip ...
| 
| >---------------------------
| 
| 
| If application first queries the message size in the receive buffer  and
| only then issues a read command may have trouble if socket discards the
| data in the meantime. Scenario is possible if one is using select()
| call.
| 
Do you have a test program which can create this condition? That would
be a great help.

From the description, this seems theoretically not possible: presumably
the peek would return 0 if a Close/Reset is in the queue. Or, if the cause
is something else, it may be the same thing I looked at in March.

However, I no longer have the test program and I am butchering my
patches in favour of the older solution. 
