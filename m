From: David Miller <davem@davemloft.net>
Date: Mon, 02 Mar 2009 11:08:03 +0000
Subject: Re: [PATCH 1/2] dccp: Minimise header option overhead in setting
Message-Id: <20090302.030803.184649276.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 28 Feb 2009 09:38:28 +0100

> This patch resolves a long-standing FIXME to dynamically update the Maximum
> Packet Size depending on actual options usage.
> 
> It uses the flags set by the feature-negotiation infrastructure to compute
> the required header option size.
> 
> Most options are fixed-size, a notable exception are Ack Vectors (required
> currently only by CCID-2). These can have any length between 3 and 1020
> bytes. As a result of testing, 16 bytes (2 bytes for type/length plus 14 Ack
> Vector cells) have been found to be sufficient for loss-free situations.
> 
> There are currently no CCID-specific header options which may appear on data
> packets, thus it is not necessary to define a corresponding CCID field as
> suggested in the old comment.
> 
> Further changes:
> ----------------
>  Adjusted the type of 'cur_mps' to match the unsigned return type of the
>  function.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
