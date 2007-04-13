From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Fri, 13 Apr 2007 13:04:30 +0000
Subject: Re: [PATCH 15/25]: Disable softirq when sending and notifying CCID
Message-Id: <39e6f6c70704130604i6413af63mc6b6d240d0d10b7c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211845.20649@strip-the-willow>
In-Reply-To: <200703211845.20649@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Arnaldo Carvalho de Melo:
> |  On 3/21/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  > [DCCP]: Disable softirq when sending and notifying CCID
> |  >
> |  > This disables softirqs when performing the CCID-specific send operation
> |  > in dccp_write_xmit, so that actual sending, and calling the CCID post-send
> |  > routine becomes an atomic unit.
> |  >
> |  > Why this needs to be done:
> |  > --------------------------
> |  >  The function dccp_write_xmit can be called both in user context (via
> |  >  dccp_sendmsg) and via timer softirq (dccp_write_xmit_timer). It does
> |  >
> |  >   1. call the CCID-specific `pre-send' routine ccid_hc_tx_send_packet()
> |  >   2. ship the skb via dccp_transmit_skb
> |  >   3. call the CCID-specific `post-send' routine ccid_hc_tx_packet_sent().
> |  >
> |  >  The last one does e.g. accounting by updating data records (as in CCID 3).
> |  >
> |  >  The transition from 2 ... 3 should be atomic and not be interrupted
> |  >  by softirqs.  The reason is that the TX and RX halves of the CCID modules
> |  >  share data structures and both halves change state. If the sending process is
> |  >  allowed to be interrupted by the reception of a DCCP packet via softirq
> |  >  handler, then state and data structures of the sender can become corrupted.
> |  >
> |  >  Here is an actual example whose effects were observed and lead to this patch:
> |  >  in CCID 3 the sender records a timestamp when ccid_hc_tx_packet_sent() is called.
> |  >  If the application is sending via dccp_sendmsg, it may be interrupted and run a
> |  >  little while later. Suppose that such interruption happens between steps (2) and
> |  >  (3) above: the packet has been sent, and immediately afterwards dccp_sendmsg is
> |  >  interrupted. Meanwhile the transmitted skb reaches the other side, and an Ack
> |  >  comes back; this Ack is processed via softirq (which is allowed to interrupt
> |  >  dccp_sendmsg); only then step (3) is performed, but too late: the timestamp
> |  >  taken in ccid3_hc_tx_packet_sent is now /after/ the Ack has come in.
> |  >
> |  >  In the observed case, negative RTT samples (i.e. Acks arriving before the
> |  >  sent packet was registered) were the result.
> |
> |  Gerrit,
> |
> |       I looked at this one now and there and I noticed that we already
> |  take a timestamp in the dccp_insert_options code path, so I think that
> |  the right fix is to avoid taking two timestamps and using the one
> |  taken at insert option time, i.e. when it gets to
> |  dccp_hc_tx_packet_sent time we already have a timestamp in the packet,
> |  i.e. avoid taking the timestamp after the packet is sent, just like
> |  you did for the REQUEST case in dccp_insert_options, makes sense?
> |
> I think you are making a good point - there is potential to integrate the use of
> timestamps (I was thinking of the icsk_ack.lrcvtime field to keep a 32-bit timestamp).

icsk is per socket, we need something per packet, that will be put
into the DCCP_OPT_TIMESTAMP and used in the packet history.

> I have a problem here - where in the code path do you mean? The only place dccp_insert_option_timestamp
> is called is in ccid3_hc_rx_insert_options. Maybe I am confusing something here.

dccp_transmit_skb
  dccp_insert_options
      dccp_insert_timestamp (now just for the REQUEST packet, but we
can change this)

> Is your intention to re-enable softirqs?

Intention is to reduce the window when softirqs are disabled, if they
need to be disabled at all.

> I am quite a bit uneasy about it. When observing the
> negative timestamps, I triggered a dump_stack. This kind of problem always happened when release_sock
> called the backlog handler.

The problem you mentioned is that we want to put it into the TX
history only when we know for sure that the packet was sent, and after
we send the packet and before we put it into TX history we could be
softirq interrupted and process an ACK for this exact packet (which
_seems_ unlikely), so we would need to disable softirqs to make the
sequence:

    err = icsk->icsk_af_ops->queue_xmit(skb, 0);
    dccp_tx_packet_sent()

Uninterrupted by softirq, so it seems we need to disable softirq just
on this smaller window, no?

But how could that happen? If we receive the ACK before the packet was
put into TX history we will not find it in the TX history in the first
place, no?

I.e. if we are interrupted before putting the packet into the TX
history and the ACK is for another packet and this other packet is in
the TX history we won't get negative RTTs.

Please bear with me, I'm just trying to get back at Net/DCCP
development, may have said something stupid as I don't have that much
time right now for checking all this in detail.

> There is so much interplay going on between CCID3 receiver and transmitter side, several timers, two
> different history structures, that I think it is safer to disable softirqs. What I haven't tested yet
> but which I think will bring further complications is when we use e.g. CCID3 for the transmitter path,
> and CCID2 (or CCID4) for the reverse path.
> Also with the bidirectional communication - it is sometimes like a little firework of timers going
> of everywhere (nofeedback timer, delack timer, response timer and all this for two independent data
> paths).

Will have to look at this in more detail, perhaps in the weekend.

- Arnaldo
