From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 21 Oct 2007 01:37:20 +0000
Subject: Re: [PATCH 12/14]: Implement both feature-local and feature-remote Sequence Window feature
Message-Id: <5640c7e00710201837jdac930ao715c8437baf277b5@mail.gmail.com>
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

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
