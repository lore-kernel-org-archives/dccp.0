From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 19:53:01 +0000
Subject: Re: [PATCH 4/14]: Integration of dynamic feature activation - part 3 (client side)
Message-Id: <5640c7e00710031253g3245711eic6576e0172b18000@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.36443@strip-the-willow>
In-Reply-To: <200710031502.36443@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Integration of dynamic feature activation - part 3 (client side)
>
> This integrates feature-activation in the client, the following details needed to be addressed:
>
> 1. When dccp_parse_options() fails, the reset code is already set, request_sent_state_process()
>    currently overrides this with `Packet Error', which is not intended - so changed to use the
>    reset code set in dccp_parse_options();
>
> 2. There was a FIXME to change the error code when dccp_ackvec_add() fails. I have looked this
>    up and found that:
>    * the check whether ackno < ISN is already made earlier,
>    * this Response is likely the first packet with an Ack number that the client gets,
>    * so when dccp_ackvec_add() fails, the reason is likely not due to a packet error.
>
>    There is another problem: when a connecting client sends a Reset in state REQUEST, the loop
>    in dccp_sendmsg(), which waits in sk_stream_wait_connect() for the transition to PARTOPEN,
>    does not (and will not) happen. The same problem also occurs if the feature negotiation
>    during connection setup fails. Thus I have lumped this case together with the following:
>
> 3. When feature negotiation fails, the socket should be marked as not usable, so that the
>    application is notified that an error occurs. This is achieved by a new label, which uses
>    an error code of `Aborted' and which sets the socket state to CLOSED, as well as sk_err.
>
> Since this addresses congestion-control initialisation, a corresponding FIXME has been removed.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
