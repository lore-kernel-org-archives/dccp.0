From: "Leandro Sales" <leandroal@gmail.com>
Date: Thu, 06 Mar 2008 20:15:25 +0000
Subject: Reporting possible bug in DCCP Feature negotiation
Message-Id: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit, during some experiments using iperf to transmit one TCP
flow against 3 DCCP flows, one DCCP thread stopped and it was shown
the following message:

"[ 6286.864021] BUG: Failed negotiation in state 2 at
net/dccp/feat.c:1370/dccp_feat_activate_values()"

Here it is the complete debug msgs including the dumped stack at the
time the error occurred:

{...}
[ 3128.785764] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 3128.785771] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 3128.923926] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 3128.923926] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 3289.686450] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 3289.686456] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 3289.687339] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 3289.687339] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 3290.431806] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 3290.431806] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 3360.243731] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 3360.243731] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 3360.409402] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 3360.409408] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 3360.532210] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 3360.532215] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 4086.271326] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 4086.271326] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 4086.286582] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 4086.286587] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 4086.663086] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 4086.663091] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 4496.981354] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 4496.981354] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 4497.049848] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 4497.049853] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 4497.259798] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 4497.259798] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
[ 4510.339903] dccp_v4_rcv: dropped packet with invalid checksum
[ 4510.345670] tfrc_calc_x_reverse_lookup: fvalue 6478 smaller than resolution
[ 4833.172100] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 4833.172100] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
[ 4833.240064] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 4833.240069] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
[ 4833.382804] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 4833.382804] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
[ 4852.431819] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 4853.013621] dccp_ackvec_add_new: Warning: large burst loss (583)
[ 4853.015678] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 4855.087753] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 4855.124335] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 4863.988418] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 4869.698085] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 4882.272518] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 4906.408436] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5467.093407] e1000: eth0: e1000_watchdog: NIC Link is Down
[ 5470.228254] e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps
Full Duplex, Flow Control: RX/TX
[ 5678.233254] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 5678.233254] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
[ 5678.253538] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 5678.253538] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
[ 5678.269784] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 5678.269789] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
[ 5690.125731] dccp_ackvec_add_new: Warning: large burst loss (943)
[ 5694.298819] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5703.277199] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5712.424335] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5712.454539] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5713.401402] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5713.413144] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5725.191982] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5735.038682] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5739.712935] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5745.579295] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5747.246785] dccp_ackvec_add_new: Warning: large burst loss (76)
[ 5747.398720] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5753.560438] printk: 2 messages suppressed.
[ 5753.560438] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 5759.789116] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6270.335006] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 6270.335006] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
[ 6270.506015] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
[ 6270.506015] dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
[ 6286.655846] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6286.864021] BUG: Failed negotiation in state 2 at
net/dccp/feat.c:1370/dccp_feat_activate_values()
[ 6286.864034] Pid: 0, comm: swapper Not tainted 2.6.25-rc3 #4
[ 6286.864034]  [<c045c6bb>] dccp_feat_activate_values+0x7b/0x200
[ 6286.864034]  [<c045f919>] dccp_create_openreq_child+0xb9/0x100
[ 6286.864034]  [<c0465226>] dccp_v4_request_recv_sock+0x46/0x1b0
[ 6286.864034]  [<c045f72e>] dccp_check_req+0x24e/0x380
[ 6286.864034]  [<c04526b0>] ipt_hook+0x0/0x20
[ 6286.864034]  [<c046543a>] dccp_v4_do_rcv+0xaa/0x160
[ 6286.864034]  [<c03fb560>] sk_receive_skb+0xc0/0x110
[ 6286.864034]  [<c04216c6>] ip_local_deliver_finish+0x66/0x120
[ 6286.864034]  [<c0421660>] ip_local_deliver_finish+0x0/0x120
[ 6286.864034]  [<c042144b>] ip_rcv_finish+0xfb/0x310
[ 6286.864034]  [<c045b9b6>] packet_rcv_spkt+0x36/0x160
[ 6286.864034]  [<c0421880>] ip_rcv+0x0/0x290
[ 6286.864034]  [<c04028ed>] netif_receive_skb+0x19d/0x230
[ 6286.864034]  [<c0405133>] process_backlog+0x63/0xd0
[ 6286.864034]  [<c0404a99>] net_rx_action+0x89/0x180
[ 6286.864034]  [<c01263e2>] __do_softirq+0x72/0xf0
[ 6286.864034]  [<c0126497>] do_softirq+0x37/0x40
[ 6286.864034]  [<c01065b0>] do_IRQ+0x40/0x70
[ 6286.864034]  [<c0104b1f>] common_interrupt+0x23/0x28
[ 6286.864034]  [<c01300d8>] sys_setdomainname+0x58/0xb0
[ 6286.864034]  [<c0102d92>] default_idle+0x52/0x80
[ 6286.864034]  [<c0102d40>] default_idle+0x0/0x80
[ 6286.864034]  [<c0102bdd>] cpu_idle+0x4d/0xd0
[ 6286.864034]  ===========[ 6288.714624] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6291.940610] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6296.571520] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6299.151136] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6299.538280] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6299.832571] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6301.420651] dccp_ackvec_add_new: Warning: large burst loss (77)
[ 6301.615940] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6301.656874] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6305.733963] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6313.671300] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6321.234212] printk: 1 messages suppressed.
[ 6321.234218] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6330.753268] printk: 5 messages suppressed.
[ 6330.753268] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6349.155197] printk: 2 messages suppressed.
[ 6349.155203] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6351.738799] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
[ 6352.184486] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
