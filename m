From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 04:43:42 +0000
Subject: Re: [PATCH 7/10]: Shift the retransmit timer for active-close into output.c
Message-Id: <5640c7e00709052143m7abf2889kce796f3805e4c169@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Shift the retransmit timer for active-close into output.c
>
> When performing active close, RFC 4340, 8.3. requires to retransmit the
> Close/CloseReq with a backoff-retransmit timer starting at intially 2 RTTs.
>
> This patch shifts the existing code for active-close retransmit timer
> into output.c, so that the retransmit timer is started when the first
> Close/CloseReq is sent. Previously, the timer was started when, after
> releasing the socket in dccp_close(), the actively-closing side had not yet
> reached the CLOSED/TIMEWAIT state.
>
> The patch further reduces the initial timeout from 3 seconds to the required
> 2 RTTs, where - in absence of a known RTT - the fallback value specified in
> RFC 4340, 3.4 is used.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
