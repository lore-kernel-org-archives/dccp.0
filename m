From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 21 Oct 2007 01:35:57 +0000
Subject: Re: [PATCH 3/10]: Dedicated auxiliary states to support passive-close
Message-Id: <5640c7e00710201835u74f51a3ama00ee94218766a92@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707121523.40095@strip-the-willow>
In-Reply-To: <200707121523.40095@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Dedicated auxiliary states to support passive-close
>
> This adds two auxiliary states to deal with passive closes:
>   * PASSIVE_1 (reached from OPEN via reception of Close) and
>   * PASSIVE_2 (reached from OPEN via reception of CloseReq)
> to the internal state machine.
>
> The PASSIVE_1 and PASSIVE_2 states represent the two ways a passive-close
> can happen in DCCP.  The addition of these states is not merely to
> increase clarity. These states are required by the implementation to
> allow a receiver to process unread data before acknowledging the received
> connection-termination-request (i.e. the Close/CloseReq).
>
> Fix:
> ----
>  This patch uses the PASSIVE_1 and PASSIVE_2 states to explicitly refer to
>  passive-closing states and to protect against external wipeout of internal
>  receive queues. The macroscopic behaviour is compatible with RFC 4340, but
>  without the auxiliary states, buggy, absurd and abnormal behaviour of the
>  socket API will continue. Which is to say, without auxiliary states it does
>  not work.
>
>  As a consequence, the count of DCCP_STATE_MASK has been increased, to account
>  for the number of new states.
>
>
> Implementation Note:
> --------------------
>  To keep compatibility with sk_stream_wait_connect():
>  * DCCP_CLOSING continues to map into TCP_CLOSING (since this state can be
>    either passive- or active-close)
>  * DCCP_CLOSEREQ maps into TCP_FIN_WAIT1 (since it is always active-close)
>
>  It is tempting to keep the clever merge of the CLOSEREQ and CLOSING states.
>  However, with the number of possible state transitions, this would require:
>
>  * quite a number of `if' statements to distinguish all predecessors of
>    the CLOSING state (server/client, active/passive, server timewait yes/no);
>
>  * two different branches from the CLOSING state:
>    - to TIMEWAIT if it is not an active server-close without keeping timewait state
>    - to CLOSED otherwise (and requiring to receive a Close instead of a Reset).
>
>  In light of this, I think it is cleaner to implement separate CLOSEREQ and CLOSING
>  states (this is done by the subsequent patches).
>
> Further documentation is on http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/closing_states/
>
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This was signed off by me on Sep 6th but seems to have got lost so:
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
