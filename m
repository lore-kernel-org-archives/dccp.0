From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 20 Aug 2010 10:40:29 +0000
Subject: Re: DCCP_BUG called
Message-Id: <20100820104028.GA3438@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
In-Reply-To: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

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

Agree, in this case it will also trigger the BUG warning. It seems that it rather should be 

   if (err < 0)
      DCCP_BUG(...)

but I need to go through this at home. One reason why this is there is the congestion control.

The assumption in hc_tx_packet_sent() is normally that the packet has been sent, there is no
second function to register packets that have not been sent. That case is treated as if the
packet got lost in the network, i.e. the loss is registered later, via the receiver feedback.

Hence it seems to me that we can remove this, or replace by a debug/warning statement.


Thanks a lot for reporting the issue, I will reply again Monday.
Gerrit
