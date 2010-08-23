From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 23 Aug 2010 05:29:45 +0000
Subject: Re: DCCP_BUG called
Message-Id: <20100823052945.GD3891@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
In-Reply-To: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Eugen,-
>>>    sudo $TC qdisc add dev $IF parent 1:10 handle 40: sfq perturb 10 limit 2
>>>
>>> taken from http://lartc.org/howto/, we receive many errors like this:
>>>
>>> [27799.691275] BUG: err=1 after ccid_hc_tx_packet_sent at
>>> /build/buildd/linux-2.6.32/net/dccp/output.c:307/dccp_write_xmit()
>>> [27799.691288]<IRQ> [<ffffffffa0441db5>] dccp_write_xmit+0x165/0x310 [dccp]
>>> [27799.691308]      [<ffffffffa0443ac0>] ? dccp_write_xmit_timer+0x0/0x80 [dccp]
>>> [27799.691315]      [<ffffffffa0443b3a>] dccp_write_xmit_timer+0x7a/0x80 [dccp]
>>>
>>> We found that they are triggered by the following code in net/dccp/output.c:
>>> 306   err = dccp_transmit_skb(sk, skb);
>>> 307   ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
>>> 308   if (err)
>>> 309     DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
>>> 310              err);
>>>
>>> Is there a way to fix to workaround that?
<snip>

>> I haven't verified this, but I am almost sure that the problem is rectified in the
>> DCCP test tree which I would like to encourage you to use for all testing, since it
>
> Thank you for your answer.  I have not yet tested with DCCP test tree  
> indeed, but I see that the code involved is there too, i.e.:
>
>  306  err = dccp_transmit_skb(sk, skb);
>  307  ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
>  308  if (err)
>  309    DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
>  310             err);
>
The above is not in the test tree, please see below. Can you please double-check
that, after pulling the tree from git://eden-feed.erg.abdn.ac.uk/dccp_exp.git,
the subtree 'dccp' is checked out? 

The 'master' branch of that tree is identical with netdev-2.6, which is why the
above two code parts are identical. The 'dccp' subtree is the actual DCCP test
tree, this in turn has the 'ccid4' subtree (which eventually will be integrated
into the test tree).


In the test tree the BUG has been demoted to a debug call,

  286          err = dccp_transmit_skb(sk, skb);
  287          if (err)
  288                  dccp_pr_debug("transmit_skb() returned err=%d\n", err);
  289          /*
  290           * Register this one as sent even if an error occurred. To the remote
  291           * end a local packet drop is indistinguishable from network loss, i.e.
  292           * any local drop will eventually be reported via receiver feedback.
  293           */
  294          ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, len);

The return code will appear in the logs if /sys/module/dccp/parameters/dccp_debug = Y
and if either the queue_xmit() function pointer returned error < 0, qdisc returned a
positive NET_XMIT_.*, or  the device a positive NETDEV_TX_.* code (linux/netdevice.h).

DCCP here does not catch the case of local drop or congestion, as it is done by TCP
in net/ipv4/tcp_output.c:tcp_transmit_skb(), the corresponding passage is:

   894          err = icsk->icsk_af_ops->queue_xmit(skb);
   895          if (likely(err <= 0))
   896                  return err;
   897
   898          tcp_enter_cwr(sk, 1);
   899
   900          return net_xmit_eval(err);

If TCP is not already in a loss state (TCP_CA_Open, TCP_CA_Disorder), this causes
a state transition to the CWR state, and 'CWR' is also signalled to an ECN-capable
receiver.

I believe that there was an earlier discussion about also catching local congestion
in DCCP, at least I see in that the reason why the above debug statement is still
there.

However, the response would need to be resolved in the TX CCID, since the handling of
loss and ECN depends on the individual CCID (RFC 4340, 12):
 * in TFRC (RFC 5348, 4342, 5622):
   -  without ECN a loss is detected 3 packets later (RFC 5348, 5.1);
   -  the local loss of the packet can not be signalled via ECN in TFRC (CCID-3/4),
      since only the "ECE" bit in the IP header is evaluated, which requires first
      to deliver the packet (RFC 4342, RFC 5622);
 * CCID-2 (RFC 4341) behaves in the same way, i.e.
   - loss detected with a delay of 3 packets or
   - packet received, but ECN-marked (ECE bit set);
 * in both cases, ECN nonce sums are returned (1-bit field in CCID-3/4 Loss Intervals 
   option, or Ack Vector type 38/39 for CCID-2), however, as described in section 12.2
   of RFC 4340, (local) packet drop destroys the ECN nonce.

Long story short -- hopefully in future there will be a way of doing something smart
in response to local drop, as currently done in TCP.
