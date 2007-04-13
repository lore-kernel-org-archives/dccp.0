From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Fri, 13 Apr 2007 12:14:47 +0000
Subject: Re: [PATCH 15/25]: Disable softirq when sending and notifying CCID
Message-Id: <39e6f6c70704130514x2cf5ee52y67d510664d0ee684@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211845.20649@strip-the-willow>
In-Reply-To: <200703211845.20649@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/21/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Disable softirq when sending and notifying CCID
>
> This disables softirqs when performing the CCID-specific send operation
> in dccp_write_xmit, so that actual sending, and calling the CCID post-send
> routine becomes an atomic unit.
>
> Why this needs to be done:
> --------------------------
>  The function dccp_write_xmit can be called both in user context (via
>  dccp_sendmsg) and via timer softirq (dccp_write_xmit_timer). It does
>
>   1. call the CCID-specific `pre-send' routine ccid_hc_tx_send_packet()
>   2. ship the skb via dccp_transmit_skb
>   3. call the CCID-specific `post-send' routine ccid_hc_tx_packet_sent().
>
>  The last one does e.g. accounting by updating data records (as in CCID 3).
>
>  The transition from 2 ... 3 should be atomic and not be interrupted
>  by softirqs.  The reason is that the TX and RX halves of the CCID modules
>  share data structures and both halves change state. If the sending process is
>  allowed to be interrupted by the reception of a DCCP packet via softirq
>  handler, then state and data structures of the sender can become corrupted.
>
>  Here is an actual example whose effects were observed and lead to this patch:
>  in CCID 3 the sender records a timestamp when ccid_hc_tx_packet_sent() is called.
>  If the application is sending via dccp_sendmsg, it may be interrupted and run a
>  little while later. Suppose that such interruption happens between steps (2) and
>  (3) above: the packet has been sent, and immediately afterwards dccp_sendmsg is
>  interrupted. Meanwhile the transmitted skb reaches the other side, and an Ack
>  comes back; this Ack is processed via softirq (which is allowed to interrupt
>  dccp_sendmsg); only then step (3) is performed, but too late: the timestamp
>  taken in ccid3_hc_tx_packet_sent is now /after/ the Ack has come in.
>
>  In the observed case, negative RTT samples (i.e. Acks arriving before the
>  sent packet was registered) were the result.

Gerrit,

     I looked at this one now and there and I noticed that we already
take a timestamp in the dccp_insert_options code path, so I think that
the right fix is to avoid taking two timestamps and using the one
taken at insert option time, i.e. when it gets to
dccp_hc_tx_packet_sent time we already have a timestamp in the packet,
i.e. avoid taking the timestamp after the packet is sent, just like
you did for the REQUEST case in dccp_insert_options, makes sense?

- Arnaldo
