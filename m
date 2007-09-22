From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 22 Sep 2007 20:16:42 +0000
Subject: Re: [PATCH 1/5] CCID 4: Adds Kconfig, Makefile, and new CCID to include/linux/dccp.h
Message-Id: <5640c7e00709221316j91d5d3co71822f796471345e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070920112021.GB1288@kikai.katei.fi>
In-Reply-To: <20070920112021.GB1288@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/20/07, Tommi Saviranta <wnd@iki.fi> wrote:
> Adds Kconfig-entries, modified Makefile, and adds DCCP_CCID enum for for
> CCID 4. Kconfig-entries are derived from CCID 3, and are probably
> invalid.
>
>
> Signed-off-by: Tommi Saviranta <wnd@iki.fi>
>
> +config IP_DCCP_CCID4
> +       tristate "CCID4 (TCP-Friendly, Small Packet Variant) (EXPERIMENTAL)"

But it doesn't depend on EXPERIMENTAL... This should be fixed.

> +       depends on IP_DCCP
> +       def_tristate IP_DCCP
> +       ---help---
> +         CCID 4 denotes the Small-Packet variant of TCP-Friendly Rate Control
> +         (TFRC-SP), an equation-based rate-controlled congestion control
> +         mechanism.  TFRC-SP is designed to be reasonably fair when competing
> +         for bandwidth with TCP-like flows, where a flow is "reasonably fair"
> +         if its sending rate is generally within a factor of two of the
> +         sending rate of a TCP flow under the same conditions.  However,
> +         TFRC-SP has a much lower variation of throughput over time compared
> +         with TCP, which makes CCID 4 more suitable than CCID 2 for
> +         applications such streaming media where a relatively smooth sending
> +         rate is of importance.
> +
> +         CCID 4 is further described in RFC xxxx,
> +         http://www.ietf.org/rfc/rfcXXXX.txt
> +
This part should say that is an Internet Draft and give the URL for
that. When it becomes a RFC a patch can then give the RFC number.

> +config IP_DCCP_CCID4_RTO
> +         int "Use higher bound for nofeedback timer"
> +         default 100
> +         depends on IP_DCCP_CCID4 && EXPERIMENTAL

This EXPERIMENTAL can be removed with the changes to add to
IP_DCCP_CCID4 as above
> +         ---help---
> +           FIXME
> +           Use higher lower bound for nofeedback timer expiration.
> +
> +           The TFRC-SP nofeedback timer normally expires after the maximum of 4
> +           RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
> +           with a small RTT this can mean a high processing load and reduced
> +           performance, since then the nofeedback timer is triggered very
> +           frequently.
> +
> +           This option enables to set a higher lower bound for the nofeedback
> +           value. Values in units of milliseconds can be set here.
> +
> +           A value of 0 disables this feature by enforcing the value specified
> +           in RFC 3448. The following values have been suggested as bounds for
> +           experimental use:
> +               * 16-20ms to match the typical multimedia inter-frame interval
> +               * 100ms as a reasonable compromise [default]
> +               * 1000ms corresponds to the lower TCP RTO bound (RFC 2988, 2.4)
> +

But Linux actually uses 250 ms for TCP here, not 1000 ms. You might
want to add that.


-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
