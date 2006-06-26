From: Johannes Deleu <Johannes.Deleu@intec.ugent.be>
Date: Mon, 26 Jun 2006 16:26:36 +0000
Subject: Re: mail voor linux mailinglist - Performance measurements with the
Message-Id: <44A00ABC.4060105@intec.ugent.be>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

> Ian McDonald wrote:
>
> One note - when using CCID3 have you turned off ackvecs via the sysctl
> as that is really for CCID2... It's probably something we should do in
> the code actually.

Thanks for the tip, after disabling ackvecs CCID3 started working again, 
packet loss remains a problem though.

> Packet loss has been implemented and is working for me. What is your
> test environment? I am using netem on a router between two boxes.

Im testing the implementation with a click router 
(http://pdos.csail.mit.edu/click/) between two linux 2.6.17.1 systems.
The click box introduces uniform packet loss according some configured 
percentage.

I'm using a simple client-server application (self-written) that dumps 
the tfrc_rx_info and the tfrc_tx_info structures and the 
tfrcrx_p/tfrctx_p fields remain zero for the entire test.

I did some quick reading in the source, and as far as I understand 
'ccid3_hx_rx_packet_recv' gets called when a packet arrives at the 
receiver. It calls 'dccp_rx_hist_add_packet' to add the packet in a 
packet list sorted by its sequence number in descending order. The 
return value of 'dccp_rx_hist_add_packet' is stored in the 'ins' value, 
which is only non-zero when packet reordering is detected. After the 
next switch statement packet loss is detected and a new loss event rate 
is calculated, but to get that far the code has to get over the switch 
statement, which is only possible if 'ins' is not zero.

As such i think the code cannot detect packetloss, maybe at best packet 
loss caused by reordering.

Does anyone agree, or did I miss something ?

best regards,
Johannes
