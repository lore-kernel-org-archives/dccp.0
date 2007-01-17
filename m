From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 17 Jan 2007 16:03:41 +0000
Subject: Re: When not resetting t_nom, negative credit never clears
Message-Id: <200701171603.41560@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701151330.20366@strip-the-willow>
In-Reply-To: <200701151330.20366@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian,

thank you for this useful input. The cases are fully possible, with the test run (which had 
zero loss and no idle times) there would then be three cases where a larger backlog could occur.

I have been asking quite a few people about the scheduling granularity problem and got the
following answers which may help deal with the third case (of the test run):

 1) CCID 3 is probably restricted in its speed by the HZ parameter, i.e. trying to send
    more than HZ packets per second will likely lead to bursts. I found that the traffic
    shaping subsystem has similar problems, as the comments in the manpage of tc-tbf(8) 
    indicate. So if we can make the system work predictably up to 15 Mbits/sec (HDTV bandwidth),
    I'd say that this would be pretty good (meaning to leave the rest for experimental / research
    extensions). It may have been not wise to expect very high bandwiths.

 2) The following might cause problems:
       * when the softirq for sending runs, it sends a whole bunch of packets
       * each device has its own hardware queue
       * additionally, each device has another Qdisc (FIFO) queue of usually 1000 packets
     This may distort transmit packet spacings; a colleague further said that when the
     buffers / queues are mostly full (as at top speed), then the whole processing slows 
     down (may be a hint for the too-high RTT estimates: in my test runs I get e.g. 5msec 
     instead of 0.1msec)

 3) We may get more predictable results with datagram-based bandwidth tests. I don't know the
    internals of iperf, but it seems that at the moment it tries to pipe as much data through
    the link as it is able to, so that during slow-start at some time X gets close to 
    X_crit = packet_size_in_bytes * HZ. When using iperf as in `iperf -u', the bandwidth
    could be restricted, to be within the range controllable by CCID 3.


Gerrit



Quoting Ian McDonald:
|  Hi there Gerrit,
|  
|  I've been thinking a bit about this and can see what's happening here
|  and with delays in general. There's a case here that I can't see the
|  RFC covering and I'll send to the IETF list a follow up to this one.
|  
|  It appears that in this case the sender can't keep up with the allowed
|  transmit rate so the negative credit gets bigger and bigger. This is
|  OK until we actually get some loss and then we won't be able to back
|  off quickly.
|  
|  The other scenario that this causes a problem if we don't reset t_nom
|  is where we have idle periods. If we go idle for 10 seconds then we
|  could potentially send heaps at that point to catch t_nom up. This
|  doesn't seem right.
|  
|  Ian
|  
|  On 16/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > Here is a log which I took after dropping the 3d patch which resets t_nom when tnom < t_now.
|  > It shows that the negative credit does not clear, hence all packets are sent in one huge burst.
|  >
|  >
|  > [   75.646215] ccid3_hc_tx_update_x: X_prev#743226, X_now#728510, X_calc=0, X_recv864255
|  > [   75.646218] ccid3_update_send_interval: t_ipiY, delta), s15, X#728510
|  > [   75.646223] ccid3_hc_tx_packet_recv: client(f651c080), RTTD98us (sampleU17us), s15, p=0, X_calc=0, X_recv864255, X#728510
|  > [   75.646264] ccid3_hc_tx_send_packet: delay=-14235
|  > [   75.646314] ccid3_hc_tx_send_packet: delay=-14226
|  > [   75.646451] ccid3_hc_tx_send_packet: delay=-14304
|  
|  
