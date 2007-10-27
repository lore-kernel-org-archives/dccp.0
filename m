From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 27 Oct 2007 22:10:35 +0000
Subject: Re: [PATCH 1/6]: Don't process Ack twice in Respond state
Message-Id: <5640c7e00710271510q5d96ed25yebfdd658d6f64122@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710271234.26379@strip-the-willow>
In-Reply-To: <200710271234.26379@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> --------> Note: for the record only, patch has been merged with
>           [DCCP]: Integration of dynamic feature activation - part 3 (client side)
>
> [DCCP]: Don't process Ack twice in Respond state
>
> This fixes a bug in the feature negotiation code: the problem is that the Ack which leads
> from RESPOND to OPEN state is processed twice, causing the following problems:
>
>  * options are parsed on request_sock in dccp_check_req and on the child socket in
>    dccp_rcv_state_process (called via dccp_child_process);
>  * redundant sequence-validity test (the one in dccp_check_req is more stringent);
>  * input is delivered to CCIDs in RESPOND state, while it should only be delivered in
>    OPEN/PARTOPEN state;
>  * since Ack Vectors (if enabled) are already loaded at that time, Ack vector accounting
>    counts the Ack which completes the initial handshake, which is confusing, since it
>    should really start in state OPEN/PARTOPEN.
>
> Note: The only states that the CCIDs/AckVecs will get input now in dccp_rcv_state_process
>       are the closing states - do we really need to feed the input to CCIDs/AckVec when
>       the connection is closing anyway???
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
