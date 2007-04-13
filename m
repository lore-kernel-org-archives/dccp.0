From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 14:06:36 +0000
Subject: Re: [PATCH 15/25]: Disable softirq when sending and notifying CCID
Message-Id: <200704131506.36311@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211845.20649@strip-the-willow>
In-Reply-To: <200703211845.20649@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > I think you are making a good point - there is potential to integrate the use of
|  > timestamps (I was thinking of the icsk_ack.lrcvtime field to keep a 32-bit timestamp).
|  
|  icsk is per socket, we need something per packet, that will be put
|  into the DCCP_OPT_TIMESTAMP and used in the packet history.
My idea was to use this field always for the last-received timestamp from the other end,
so that it would have the meaning `last time a data packet with timestamp was received'.

|  > I have a problem here - where in the code path do you mean? The only place dccp_insert_option_timestamp
|  > is called is in ccid3_hc_rx_insert_options. Maybe I am confusing something here.
|  
|  dccp_transmit_skb
|    dccp_insert_options
|        dccp_insert_timestamp (now just for the REQUEST packet, but we
|  can change this)
Ah I see - but that means a timestamp per every packet sent. CCID2 for instance does not need
timestamps. I think that the specific problem of negative RTTs will no longer apply since now
the timestamp is taken after everything else has happened - including socket (sk) lock times.



|  > Is your intention to re-enable softirqs?
|  
|  Intention is to reduce the window when softirqs are disabled, if they
|  need to be disabled at all.
|  
|  > I am quite a bit uneasy about it. When observing the
|  > negative timestamps, I triggered a dump_stack. This kind of problem always happened when release_sock
|  > called the backlog handler.
|  
|  The problem you mentioned is that we want to put it into the TX
|  history only when we know for sure that the packet was sent, and after
|  we send the packet and before we put it into TX history we could be
|  softirq interrupted and process an ACK for this exact packet (which
|  _seems_ unlikely), so we would need to disable softirqs to make the
|  sequence:
|  
|      err = icsk->icsk_af_ops->queue_xmit(skb, 0);
|      dccp_tx_packet_sent()
|  
|  Uninterrupted by softirq, so it seems we need to disable softirq just
|  on this smaller window, no?
I think you mention a second problem, which is independent of the synchronisation problem that this 
patch aims at tackling. So if I understand you correctly, do you mean the following in dccp_write_xmit?
	err = icsk->icsk_af_ops->queue_xmit(skb, 0);   
	if (net_xmit_eval(err) = 0)
		dccp_tx_packet_sent();
The problem I found with this second issue is that at this time skb_dequeue(&sk->sk_write_queue) has
already been called, so for all accounting purposes the packet is written off as `sent'. The CCID 
infrastructure had also given green light via ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb),
so telling it not to consider the packet as sent would give it the wrong information. The problem is
benign, I think, since it will come up as loss; so that at the end of the day the CCID infrastructure
will register it. (Also the case seems very rare under normal conditions).

 
|  But how could that happen? If we receive the ACK before the packet was
|  put into TX history we will not find it in the TX history in the first
|  place, no?
My admittedly modest understanding of NAPI and the way the packets are processed in the receive path
is that the simple idea of 'A sends Data/DataAck and B sends an Ack back' never happens in reality as
described.  More than one packets are dequeued from the hardware ring buffer of the interface. 

So when we allow softirq processing to happen in parallel with the send operation then I am concerned that
this will mess up the interaction of receive-CCID and send-CCID.
Can the case that sending happens on one active CPU and concurrent receive happens on another CPU in softirq
be dismissed?

Since the tx queue can be long, the time that the sk lock is held can potentially be quite long.
Especially when dccp_wait_for_ccid() always returns 0; then the sk lock is held until the entire queue
has been emptied.

I had initially put the local_bh_disable() earlier, the setting used in the patch was the smallest possible
time window I could find. 

|  I.e. if we are interrupted before putting the packet into the TX
|  history and the ACK is for another packet and this other packet is in
|  the TX history we won't get negative RTTs.
|  
|  Please bear with me, I'm just trying to get back at Net/DCCP
|  development, may have said something stupid as I don't have that much
|  time right now for checking all this in detail.
Part of the patch is a precaution, so if we can be 100% sure that sending and receiving a burst of 
packets never happens in parallel, then it is probably safe to do without disabling softirqs here.
But if it is not, then this would allow nasty timing problems.
I think this is more of a SMP / NAPI problem.
