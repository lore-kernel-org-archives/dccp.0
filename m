From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 09 Oct 2007 20:09:09 +0000
Subject: Re: [PATCH v2 7/8]: Handle timestamps on Request/Response exchange separately
Message-Id: <5640c7e00710091309v44e8a57iaab38d5a88cf1ad3@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710091145.44028@strip-the-willow>
In-Reply-To: <200710091145.44028@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/9/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This is a reworked patch, using the suggested static allocation, with the following differences
>  * made the field names consistent between request_sock and dccp_sock;
>  * since the time between receiving a Timestamp and sending the Timestamp Echo is not huge, it makes
>    sense to use dccp_timestamp() instead of ktime; which also halved the size of the field;
>  * whitespace adapted to make assignments toe in line;
>  * added a warning when 0-valued timestamps arrive, since we use this to test whether one was present.
>
> I have tested this for functioning in two different environments.
>
> ----------------------------------> Patch v2 <------------------------------------------------------------
> [DCCP]: Handle timestamps on Request/Response exchange separately
>
> In DCCP, timestamps can occur on packets anytime, CCID3 uses a timestamp(/echo) on the Request/Response
> exchange. This patch addresses the following situation:
>         * timestamps are recorded on the listening socket;
>         * Responses are sent from dccp_request_sockets;
>         * suppose two connections reach the listening socket with very small time in between:
>         * the first timestamp value gets overwritten by the second connection request.
>
> This is not really good, so this patch separates timestamps into
>  * those which are received by the server during the initial handshake (on dccp_request_sock);
>  * those which are received by the client or the client after connection establishment.
>
> As before, a timestamp of 0 is regarded as indicating that no (meaningful) timestamp has been
> received (in addition, a warning message is printed if hosts send 0-valued timestamps).
>
> The timestamp-echoing now works as follows:
>  * when a timestamp is present on the initial Request, it is placed into dreq, due to the
>    call to dccp_parse_options in dccp_v{4,6}_conn_request;
>  * when a timestamp is present on the Ack leading from RESPOND => OPEN, it is copied over
>    from the request_sock into the child cocket in dccp_create_openreq_child;
>  * timestamps received on an (established) dccp_sock are treated as before.
>
> Since Elapsed Time is measured in hundredths of milliseconds (13.2), the new dccp_timestamp()
> function is used, as it is expected that the time between receiving the timestamp and
> sending the timestamp echo will be very small against the wrap-around time. As a byproduct,
> this allows smaller timestamping-time fields.
>
> Furthermore, inserting the Timestamp Echo option has been taken out of the block starting with
> '!dccp_packet_without_ack()', since Timestamp Echo can be carried on any packet (5.8 and 13.3).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
