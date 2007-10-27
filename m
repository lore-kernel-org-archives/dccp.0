From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 27 Oct 2007 22:26:00 +0000
Subject: Re: [PATCH 5/6]: Deadlock and spurious timeouts when Ack Ratio > cwnd
Message-Id: <5640c7e00710271526i5a321ef1h3893d5c5cff1d9e5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710271234.34898@strip-the-willow>
In-Reply-To: <200710271234.34898@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID2]: Deadlock and spurious timeouts when Ack Ratio > cwnd
>
> This patch removes a bug in the current code. I agree with Andrea's comment
> that there is a problem here but the way it is treated does not fix it.
>
> The problem is that whenever Ack Ratio > cwnd, starvation/deadlock occurs:
>  * the receiver will not send an Ack until (Ack Ratio - cwnd) data packets
>    have arrived;
>  * the sender will not send any data packet before the receipt of an Ack
>    advances the send window.
> The only way that the connection then progresses was via RTO timeout. In one
> extreme case (bulk transfer), it was observed that this happened for every single
> packet; i.e. hundreds of packets, each a RTO timeout of 1..3 seconds apart:
> a transfer which normally would take a fraction of a second thus grew to
> several minutes.
>
> The solution taken by this approach is to observe the relation
>
>                    "Ack Ratio <= cwnd"
>
> by using the constraint (1) from RFC 4341, 6.1.2; i.e. set
>
>                  Ack Ratio = ceil(cwnd / 2)
>
> and update it whenever either Ack Ratio or cwnd change. This ensures that
> the deadlock problem can not arise.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
