From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 20 Aug 2010 05:15:40 +0000
Subject: Re: DCCP_BUG called
Message-Id: <20100820051540.GA5414@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
In-Reply-To: <4C6D3DD8.4080606@pu-pm.univ-fcomte.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>   sudo $TC qdisc add dev $IF root handle 1: htb default 10
>   sudo $TC class add dev $IF parent 1: classid 1:10 htb rate $up_rate
>   sudo $TC filter add dev $IF protocol ip parent 1:0 prio 1 u32 match ip 
> dst $dest flowid 1:10
>   sudo $TC qdisc add dev $IF parent 1:10 handle 40: sfq perturb 10 limit 2
>
> taken from http://lartc.org/howto/, we receive many errors like this:
>
> [27799.691275] BUG: err=1 after ccid_hc_tx_packet_sent at  
> /build/buildd/linux-2.6.32/net/dccp/output.c:307/dccp_write_xmit()
> [27799.691288] <IRQ>  [<ffffffffa0441db5>] dccp_write_xmit+0x165/0x310  
> [dccp]
> [27799.691308]  [<ffffffffa0443ac0>] ? dccp_write_xmit_timer+0x0/0x80 [dccp]
> [27799.691315]  [<ffffffffa0443b3a>] dccp_write_xmit_timer+0x7a/0x80 [dccp]
>
> We found that they are triggered by the following code in net/dccp/output.c:
> 306   err = dccp_transmit_skb(sk, skb);
> 307   ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
> 308   if (err)
> 309     DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
> 310              err);
>
> Is there a way to fix to workaround that?

The 'err = 1' is triggered because the qdisc can refuse to take a packet, so that

 #define NET_XMIT_DROP           0x01    /* skb dropped                  */

is returned. Thus what you are seeing is not a real bug, but rather a misplaced
BUG statement. 

I haven't verified this, but I am almost sure that the problem is rectified in the
DCCP test tree which I would like to encourage you to use for all testing, since it
contains more up-to-date fixes (patches of the test tree shall soon be submitted).

You can pull the test tree from

    git://eden-feed.erg.abdn.ac.uk/dccp_exp         [subtree 'dccp']
    http://[same-address]
    
Further instructions and alternative check-out possibilities are described on 

    http://www.linuxfoundation.org/collaborate/workgroups/networking/dccp_testing#Experimental_DCCP_source_tree


Gerrit
