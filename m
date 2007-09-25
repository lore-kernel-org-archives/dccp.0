From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 19:27:03 +0000
Subject: Re: [PATCH 1/8]: Add FIXME for send_delayed_ack
Message-Id: <5640c7e00709251227m2c697024k4bd9085c383883@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709251529.52965@strip-the-willow>
In-Reply-To: <200709251529.52965@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/26/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Add FIXME for send_delayed_ack
>
> This adds a FIXME to signal that the function dccp_send_delayed_ack is nowhere
> used in the entire DCCP/CCID code.
>
> Using a delayed Ack timer is suggested in 11.3 of RFC 4340, but it has also
> rather subtle implications for the Ack-Ratio-accounting.
>
> CCID2 does not use this (maybe it should).
>
> I think leaving the function in is good, in case someone wants to implement
> this.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

How about using #if 0, #endif around it to keep the code in the tree
but not compiled.

This is done a fair bit elsewhere and if never used it gets removed.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
