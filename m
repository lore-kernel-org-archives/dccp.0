From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 30 Jun 2006 01:42:57 +0000
Subject: Re: mail voor linux mailinglist - Performance measurements with the latest version of the DCCP (CCID
Message-Id: <5640c7e00606291842p1dabe561i598e8cba0c4739c0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <44A00ABC.4060105@intec.ugent.be>
In-Reply-To: <44A00ABC.4060105@intec.ugent.be>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> I'm using a simple client-server application (self-written) that dumps
> the tfrc_rx_info and the tfrc_tx_info structures and the
> tfrcrx_p/tfrctx_p fields remain zero for the entire test.
>
> I did some quick reading in the source, and as far as I understand
> 'ccid3_hx_rx_packet_recv' gets called when a packet arrives at the
> receiver. It calls 'dccp_rx_hist_add_packet' to add the packet in a
> packet list sorted by its sequence number in descending order. The
> return value of 'dccp_rx_hist_add_packet' is stored in the 'ins' value,
> which is only non-zero when packet reordering is detected. After the
> next switch statement packet loss is detected and a new loss event rate
> is calculated, but to get that far the code has to get over the switch
> statement, which is only possible if 'ins' is not zero.
>
> As such i think the code cannot detect packetloss, maybe at best packet
> loss caused by reordering.

What do you mean packet loss caused by reordering? This is not TCP so
we don't keep sending ACKs of latest sequence number in order to get a
retransmit... Can you explain what you mean?

>
> Does anyone agree, or did I miss something ?
>
I think you missed something.

As I read the code the only thing we are guilty of possibly is that we
don't declare this as "unloss" when the packet arrives out of order.
We check whether they are in the same loss event and we throw packets
away out of history when we have more than 4 in the history so we
can't change it from loss back to no loss. I'm not sure without
further reading whether we should be storing more history - it would
help but I can't find it quickly reading whether it is a requirement.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
