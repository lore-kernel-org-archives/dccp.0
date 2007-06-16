From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 14:33:42 +0000
Subject: Re: [PATCH 2/3]: Sending time: update to ktime_t and bug-fix
Message-Id: <39e6f6c70706160733g6b0444d2v6049fae134f1497b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091932.38162@strip-the-willow>
In-Reply-To: <200706091932.38162@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/9/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Sending time: update to ktime_t and bug-fix
>
> This updates the computation of t_nom and t_last_win_count to use the newer
> gettimeofday interface.
>
> The second point of this patch is to fix a bug in the send time processing:
>
>   ccid3_hc_tx_send_packet currently returns 0 when the time difference
>   between current time and t_nom is less than 1000 microseconds.
>
>   In this case the packet is sent immediately; but, unlike other packets
>   that can be emitted on first attempt, it will not have its window
>   counter updated and its options set as required. This is a bug.
>
> Fix: Require the time difference to be at least 1000 microseconds. The
>      algorithm then converges: time differences > 1000 microseconds trigger the
>      timer in dccp_write_xmit; after timer expiry this function is tried again;
>      when the time difference is less than 1000, the packet will have its options
>      added and window counter updated as required.

I'm breaking this into two patches for you this time :-)

- Arnaldo
