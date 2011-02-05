From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 05 Feb 2011 13:57:10 +0000
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Message-Id: <20110205135710.GA4752@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20110202.170750.229739784.davem@davemloft.net>
In-Reply-To: <20110202.170750.229739784.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| I've left the DCCP code to keep using RFC3390 logic, if they
| wish to adopt this change in their code they can do so by
| simply deleting the rfc33390_bytes_to_packets() function and
| using TCP_INIT_CWND in their assignment.
| 
|  include/net/tcp.h      |   12 +++---------
|  net/dccp/ccids/ccid2.c |    9 +++++++++
Thank you for keeping the compatility, this seems an excellent way forward.

The change only affects CCID-2, TCP-like congestion control. This still has
some unresolved issues (related to cwnd) in its implementation.

Once these have been resolved, we can return to tracking the state of the 
art in TCP, for the moment your patch works best.
