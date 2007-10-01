From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 01 Oct 2007 19:34:08 +0000
Subject: Re: [PATCH 2/3]: One more exemption from full sequence number checks
Message-Id: <5640c7e00710011234h52eab216v715234ff95b6ab58@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709291742.54639@strip-the-willow>
In-Reply-To: <200709291742.54639@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/30/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: One more exemption from full sequence number checks
>
> This fixes the following problem: client connects to peer which has no DCCP
> enabled or loaded; ICMP error messages ("Protocol Unavailable") can be seen
> on the wire, but the application hangs. Reason: ICMP packets don't get through
> to dccp_v4_err.
>
> When reporting errors, a sequence number check is made for the DCCP packet
> that had caused an ICMP error to arrive.
> Such checks can not be made if the socket is in state LISTEN, RESPOND (which
> in the implementation is the same as LISTEN), or REQUEST, since update_gsr()
> has not been called in these states, hence the sequence window is 0..0.
>
> This patch fixes the problem by adding the REQUEST state as another exemption
> to the window check. The error reporting now works as expected on connecting.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Does this affect DCCP on IP v6? If it does, it should be fixed also.
If it doesn't then can you add that to the changelog to stop others
asking also.
