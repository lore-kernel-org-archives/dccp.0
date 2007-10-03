From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 03 Oct 2007 22:14:30 +0000
Subject: Re: [PATCH 12/14]: Implement both feature-local and feature-remote Sequence Window feature
Message-Id: <5640c7e00710031514x4db8e421nd18d1594fa2ba2@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710031502.54147@strip-the-willow>
In-Reply-To: <200710031502.54147@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Implement both feature-local and feature-remote Sequence Window feature
>
> This adds full support for both local/remote Sequence Window feature, from which the
>  * sequence-number-validity (W) and
>  * acknowledgment-number-validity (W') windows
> derive as specified in RFC 4340, 7.5.3.
>
> Specifically, the following changes are introduced:
>   * integrated new socket fields into dccp_sk;
>   * updated the update_gsr/gss routines with regard to these fields, using modulo-48 arithmetic;
>   * updated handler code: the Sequence Window feature is located at the TX side, so the local feature is
>     meant if the handler-rx flag is false;
>   * the initialisation of `rcv_wnd' in reqsk is removed, since
>         (i)   rcv_wnd is not used by the code anywhere;
>         (ii)  sequence number checks are not done in the LISTEN state (table in 7.5.3);
>         (iii) dccp_check_req already performs more stringent checks on the Ack number validity.
>
> Until the handshake completes with activating negotiated values, the Sequence-Window default values
> (100) are used. As indicated by the comment, I think that this is more than enough. Further, it only
> applies to the client, since:
>   * client's AWL is set in dccp_connect_init(),
>   * client's SWL is set in dccp_rcv_request_sent_state_process() (from the ISR of the Response),
>   * server's AWL/SWL are set when the new child socket is created in dccp_create_openreq_child();
>     but at this stage dccp_feat_activate_values() has already updated the local/remote Sequence
>     Window feature of the server, so it is using the latest values,
>   * dccp_check_req() (used on reqsk's) does not need AWL/SWL and performs more stringent checks.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Hmmm.... I had multiple problems when the default window was 100 when
testing in the past - from memory particularly with long RTT, low loss
links. Try putting 100 ms delay on a 100 Mbits/link and see what
happens...

See 7.5.2 of RFC4340:
   A proper Sequence Window/A value must reflect the number of packets
   DCCP A expects to be in flight.  Only DCCP A can anticipate this
   number.  Values that are too small increase the risk of the endpoints
   getting out sync after bursts of loss, and values that are much too
   small can prevent productive communication whether or not there is
   loss.  On the other hand, too-large values increase the risk of
   connection hijacking; Section 7.5.5 quantifies this risk.  One good
   guideline is for each endpoint to set Sequence Window to about five
   times the maximum number of packets it expects to send in a round-
   trip time.  Endpoints SHOULD send Change L(Sequence Window) options,
   as necessary, as the connection progresses.  Also, an endpoint MUST
   NOT persistently send more than its Sequence Window number of packets
   per round-trip time; that is, DCCP A MUST NOT persistently send more
   than Sequence Window/A packets per RTT.


Or am I missing something again. Maybe you are setting this
automatically and increasing as required? (I haven't gone through and
re-read current source code).

Ian
