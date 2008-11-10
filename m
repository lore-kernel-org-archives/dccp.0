From: David Miller <davem@davemloft.net>
Date: Mon, 10 Nov 2008 21:15:15 +0000
Subject: Re: [PATCH 1/4] dccp: Limit feature negotiation to connection
Message-Id: <20081110.131515.155716151.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1225950014-6337-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1225950014-6337-2-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu,  6 Nov 2008 06:40:11 +0100

> This patch limits feature-negotiation to the connnection-setup phase:
> 
>  1. Although it is theoretically possible to perform feature negotiation at any
>     time (and RFC 4340 supports this), in practice this is prohibitively complex,
>     as it requires to put traffic on hold for each new negotiation.
>  2. As a byproduct of restricting feature negotiation to connection setup, the
>     feature-negotiation retransmit timer is no longer required. This part is now
>     mapped onto the protocol-level retransmission.
>     Details indicating why timers are no longer needed can be found on
>     http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/\
> 	                                      implementation_notes.html
> 
> This patch disables anytime negotiation, subsequent patches work out full
> feature negotiation support for connection setup.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied.
