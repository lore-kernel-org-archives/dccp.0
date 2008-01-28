From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 28 Jan 2008 17:59:18 +0000
Subject: Re: [PATCH 3/6] [DCCP]: Bug-Fix - AWL was never updated
Message-Id: <5640c7e00801280959k456fd080l3f29953c0d74eb16@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1201515376-8280-4-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1201515376-8280-4-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Jan 28, 2008 11:16 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This patch was triggered by finding the  following message in the syslog:
>  "kernel: dccp_check_seqno: DCCP: Step 6 failed for DATAACK packet, [...]
>    P.ackno exists or LAWL(82947089) <= P.ackno(82948208)
>                                     <= S.AWH(82948728), sending SYNC..."
>
> Note the difference between AWH and AWL: it is 1639 packets (while Sequence
> Window was actually at 100). A closer look at the trace showed that
> LAWL = AWL = 82947089 equalled the ISS on the Response.
>
> The cause of the bug was that AWL was only ever set on the first packet - the
> DCCP-Request sent by dccp_v{4,6}_connect().
>
> The fix is to continually update AWL/AWH with each new packet (as GSS=AWH).
>
> In addition, AWL/AWH are now updated to enforce more stringent checks on the
> initial sequence numbers when connecting:
>  * AWL is initialised to ISS and remains at this value;
>  * AWH is always set to GSS (via dccp_update_gss());
>  * so on the first Request: AWL =      AWH = ISS,
>    and on the n-th Request: AWL = ISS, AWH = ISS+n.
>
> As a consequence, only Response packets that refer to Requests sent by this
> host will pass, all others are discarded. This is the intention and in effect
> implements the initial adjustments for AWL as specified in RFC 4340, 7.5.1.
>
> Note: A problem that remains is that ISS can potentially be under-run even after
>       the initial handshake; this is addressed a subsequent patch.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Yes I had seen this and had worked out that variables weren't being
updated as they should be but hadn't got as far as a fix before I
stopped my coding days so much :-(

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
