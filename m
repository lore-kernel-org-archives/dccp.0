From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 16 Jan 2007 21:35:13 +0000
Subject: Re: When not resetting t_nom, negative credit never clears
Message-Id: <5640c7e00701161335n3f3610d5x9812ee53fa7bb901@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701151330.20366@strip-the-willow>
In-Reply-To: <200701151330.20366@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi there Gerrit,

I've been thinking a bit about this and can see what's happening here
and with delays in general. There's a case here that I can't see the
RFC covering and I'll send to the IETF list a follow up to this one.

It appears that in this case the sender can't keep up with the allowed
transmit rate so the negative credit gets bigger and bigger. This is
OK until we actually get some loss and then we won't be able to back
off quickly.

The other scenario that this causes a problem if we don't reset t_nom
is where we have idle periods. If we go idle for 10 seconds then we
could potentially send heaps at that point to catch t_nom up. This
doesn't seem right.

Ian

On 16/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Here is a log which I took after dropping the 3d patch which resets t_nom when tnom < t_now.
> It shows that the negative credit does not clear, hence all packets are sent in one huge burst.
>
>
> [   75.646215] ccid3_hc_tx_update_x: X_prev#743226, X_now#728510, X_calc=0, X_recv864255
> [   75.646218] ccid3_update_send_interval: t_ipiY, delta), s15, X#728510
> [   75.646223] ccid3_hc_tx_packet_recv: client(f651c080), RTTD98us (sampleU17us), s15, p=0, X_calc=0, X_recv864255, X#728510
> [   75.646264] ccid3_hc_tx_send_packet: delay=-14235
> [   75.646314] ccid3_hc_tx_send_packet: delay=-14226
> [   75.646451] ccid3_hc_tx_send_packet: delay=-14304


-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
