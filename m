From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 20:01:21 +0000
Subject: Re: [PATCH 6/14]: Remove now unused parts of the old CCID interface
Message-Id: <5640c7e00710031301g27a1043et8fc958a13b6ef5c9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.40855@strip-the-willow>
In-Reply-To: <200710031502.40855@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Remove now unused parts of the old CCID interface
>
> The TX/RX CCIDs of the minisock are now redundant; similar to the Ack Vector case,
> their value equals initially that of the sysctl, but at the end of feature negotiation
> may be something different.
>
> The old interface removed by this patch thus has been replaced by the newer interface to
> dynamically query the currently loaded CCIDs earlier in this patch set.
>
> Also removed the constructors for the TX CCID and the RX CCID, since the switch rx/non-rx
> is done by the handler in minisocks.c (and the handler is the only place in the code
> where CCIDs are loaded).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
