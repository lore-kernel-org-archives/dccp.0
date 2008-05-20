From: "Leandro Sales" <leandroal@gmail.com>
Date: Tue, 20 May 2008 18:29:00 +0000
Subject: Re: Reporting possible bug in DCCP Feature negotiation
Message-Id: <5bc4c4570805201129v4c061d1fj59dc6557c01cbd74@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
In-Reply-To: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello Gerrit,
   it is nice to know that you confirmed my bug report. Good job, I
just read the attached patch. Is the patch already in the test tree?

Thank you,
Leandro.

On Sun, May 18, 2008 at 1:09 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> Leandro,
>
> I can now confirm that this is indeed a bug. It is caused by the client
> not retransmitting Confirm options while in state PARTOPEN.
>
> A detailed analysis with capture files has been uploaded to
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/why_retransmit_confirms/
>
> The fix is to retransmit Confirm options until entering OPEN state.
> A patch is attached and has been put into the test tree.
>
> There is another bug fix involved, this is documented on the website,
> will send second patch subsequently.
>
> Many thanks for testing and reporting.
> Gerrit
>
> | Hi Gerrit, during some experiments using iperf to transmit one TCP
> | flow against 3 DCCP flows, one DCCP thread stopped and it was shown
> | the following message:
> |
> | "[ 6286.864021] BUG: Failed negotiation in state 2 at
> | net/dccp/feat.c:1370/dccp_feat_activate_values()"
> |
> | Here it is the complete debug msgs including the dumped stack at the
> | time the error occurred:
> |
> | {...}
> | [ 6286.864021] BUG: Failed negotiation in state 2 at
> | net/dccp/feat.c:1370/dccp_feat_activate_values()
> | [ 6286.864034] Pid: 0, comm: swapper Not tainted 2.6.25-rc3 #4
> | [ 6286.864034]  [<c045c6bb>] dccp_feat_activate_values+0x7b/0x200
> | [ 6286.864034]  [<c045f919>] dccp_create_openreq_child+0xb9/0x100
> | [ 6286.864034]  [<c0465226>] dccp_v4_request_recv_sock+0x46/0x1b0
> | [ 6286.864034]  [<c045f72e>] dccp_check_req+0x24e/0x380
> | [ 6286.864034]  [<c04526b0>] ipt_hook+0x0/0x20
> | [ 6286.864034]  [<c046543a>] dccp_v4_do_rcv+0xaa/0x160
> | [ 6286.864034]  [<c03fb560>] sk_receive_skb+0xc0/0x110
> | [ 6286.864034]  [<c04216c6>] ip_local_deliver_finish+0x66/0x120
> | [ 6286.864034]  [<c0421660>] ip_local_deliver_finish+0x0/0x120
> | [ 6286.864034]  [<c042144b>] ip_rcv_finish+0xfb/0x310
> | [ 6286.864034]  [<c045b9b6>] packet_rcv_spkt+0x36/0x160
> | [ 6286.864034]  [<c0421880>] ip_rcv+0x0/0x290
> | [ 6286.864034]  [<c04028ed>] netif_receive_skb+0x19d/0x230
> | [ 6286.864034]  [<c0405133>] process_backlog+0x63/0xd0
> | [ 6286.864034]  [<c0404a99>] net_rx_action+0x89/0x180
> | [ 6286.864034]  [<c01263e2>] __do_softirq+0x72/0xf0
> | [ 6286.864034]  [<c0126497>] do_softirq+0x37/0x40
> | [ 6286.864034]  [<c01065b0>] do_IRQ+0x40/0x70
> | [ 6286.864034]  [<c0104b1f>] common_interrupt+0x23/0x28
> | [ 6286.864034]  [<c01300d8>] sys_setdomainname+0x58/0xb0
> | [ 6286.864034]  [<c0102d92>] default_idle+0x52/0x80
> | [ 6286.864034]  [<c0102d40>] default_idle+0x0/0x80
> | [ 6286.864034]  [<c0102bdd>] cpu_idle+0x4d/0xd0
> | [ 6286.864034]  ===========


--
Leandro Melo de Sales.
Pervasive and Embedded Computing Laboratory
BRisa and E-Phone Projects Manager
Network Admin @ http://embedded.ufcg.edu.br/indexen.html
+55 83 3310-1404 (extension 208)

http://www.leandrosales.com/
