From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 21:05:18 +0000
Subject: Re: [PATCH 9/14]: Phase out the use of boolean flag for Ack Vectors
Message-Id: <5640c7e00710031405w74b0906ex85f914702e19d34@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.47513@strip-the-willow>
In-Reply-To: <200710031502.47513@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [ACKVEC]: Phase out the use of boolean flag for Ack Vectors
>
> This removes the use of the sysctl and the minisock variable for the Send Ack
> Vector feature, which is now handled fully dynamically via feature negotiation;
> i.e. when CCID2 is enabled, Ack Vectors are automatically enabled (as per RFC 4341, 4.).
>
> Using a sysctl in parallel to this implementation would open the door to crashes, since
> much of the code relies on tests of the boolean minisock / sysctl variable. Thus, this
> patch replaces all tests of type
>
>         if (dccp_msk(sk)->dccpms_send_ack_vector)
>                 /* ... */
> with
>         if (dp->dccps_hc_rx_ackvec != NULL)
>                 /* ... */
>
> The dccps_hc_rx_ackvec is allocated by the dccp_hdlr_ackvec() when feature negotiation
> concluded that Ack Vectors are to be used on the half-connection. Otherwise, it is NULL
> (due to dccp_init_sock/dccp_create_openreq_child), so that the test is a valid one.
>
> The activation handler for Ack Vectors is called as soon as the feature negotiation has
> concluded:
>  * at the server when the Ack marking the transition RESPOND => OPEN arrives;
>  * at the client after it has sent above ACK, marking the transition REQUEST => PARTOPEN.
>
> To support Ack Vectors as early as possible, adding the sequence number from the server-Response
> in dccp_rcv_request_sent_state_process() has been enabled by shifting the call to dccp_ackvec_add()
> after dccp_feat_activate_values() (which takes care of all the feature activation).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -372,7 +372,6 @@ static inline unsigned int dccp_hdr_len(
>  #define DCCPF_INITIAL_SEQUENCE_WINDOW          100
>  #define DCCPF_INITIAL_ACK_RATIO                        2
>  #define DCCPF_INITIAL_CCID                     DCCPC_CCID2
> -#define DCCPF_INITIAL_SEND_ACK_VECTOR          1
>  /* FIXME: for now we're default to 1 but it should really be 0 */
>  #define DCCPF_INITIAL_SEND_NDP_COUNT           1
>
Not sure if the fixme applies to ack_vector or send_ndp_count so
unsure if that should be removed also.
