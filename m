From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 00:21:03 +0000
Subject: Re: Test tree patch inventory - update
Message-Id: <20071121002103.GB24995@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20071120201041.GA24995@ghostprotocols.net>
In-Reply-To: <20071120201041.GA24995@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Nov 17, 2007 at 03:42:52PM +0000, Gerrit Renker escreveu:
>                         Test Tree Inventory
> 		        ========= 
> 4. Support for passive-close without flushing unread data
> ---------------------------------------------------------
> This set actually involves only 5 patches, the last one is according to your suggestion.
> 
> 	[DCCP]: Separate protocol states into general/specific

I dropped this one, see next explanation.

> 	[DCCP]: Make PARTOPEN an autonomous state

Here I made DCCP_PARTOPEN = TCP_MAX_STATES, that DCCP_INTRINSECS was not
used anywhere and this just means that states >= TCP_MAX_STATES are
DCCP only states.
 
> 	[DCCP]: Dedicated auxiliary states to support passive-close

I'll combine this with the next one.

> 	[DCCP]: Basic support for passive-close

What happens if we receive a second CloseReq or a second Close packet or
if the server performed an active close?

In all these cases we're leaking an skb, no? As dccp_rcv_close{req}
before always used dccp_fin there wasn't a need for returning a value
from these functions, but now we better return if we used the skb or
not, so that when back to __dccp_rcv_established and
dccp_rcv_state_process we can discard the packet.

- Arnaldo
