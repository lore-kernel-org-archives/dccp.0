From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 05 Oct 2007 06:42:03 +0000
Subject: Re: [PATCH 2/5]: Support for the exchange of NN options in established state
Message-Id: <5640c7e00710042342v4ca1a38ftde34c54e97e48e68@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710041501.53141@strip-the-willow>
In-Reply-To: <200710041501.53141@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/5/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Support for the exchange of NN options in established state
>
> This patch introduces a variant of feature negotiation which differs from
> feature negotiation during connection setup in the following aspects.
>  * It is a restricted variant - only NN options can be exchanged;
>  * NN options are activated directly after validating them. The rationale is
>    that a peer must accept every valid NN value (RFC 4340, 6.3.2), hence it
>    will either accept the value and send a ConfirmR, or it will send an
>    empty Confirm (which will reset the connection according to FN rules).
>  * An Ack is scheduled directly after activation to accelerate communicating
>    the update to the peer.
>
> The facility of exchanging NN options is currently only needed by CCID2's Ack Ratio
> (RFC 4341, 6.1.2). Although the code will in principle work for any NN option, this
> fact has been the reason for limiting the current use to Ack Ratio.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
