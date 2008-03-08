From: "Leandro Sales" <leandroal@gmail.com>
Date: Sat, 08 Mar 2008 16:14:03 +0000
Subject: Re: Reporting possible bug in DCCP Feature negotiation
Message-Id: <5bc4c4570803080814h243e295bj4d41efb6bef12fc1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
In-Reply-To: <5bc4c4570803061215s36fac06ctc2015cc2d079ea9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Sat, Mar 8, 2008 at 12:56 PM, Leandro Sales <leandroal@gmail.com> wrote:
> On Fri, Mar 7, 2008 at 10:15 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>  > | Hi Gerrit, during some experiments using iperf to transmit one TCP
>  >  | flow against 3 DCCP flows, one DCCP thread stopped and it was shown
>  >  | the following message:
>  >  |
>  >  | "[ 6286.864021] BUG: Failed negotiation in state 2 at
>  >  | net/dccp/feat.c:1370/dccp_feat_activate_values()"
>  >  |
>  >  Did it really stop? The trigger is only possible during the initial
>  >  handshake, this is the only place where this activation-code is
>  >  executed. So almost certainly it failed at the begin of the connection.
>
>  I started 3 DCCP connection, just 2 transmitted. Then the third is the
>  one that had the problem.
>
>
>  >
>  >  I am assuming that both end hosts have identical kernels, if they are
>  >  using different versions of DCCP, this would be a likely cause.
>
>  2.6.25-rc3 in both sides
>
>
>  >
>  >  The log is very interesting, but I can't say whether the error message
>  >  is really a bug or if the action was correct under the given
>  >  circumstances; below is explanation of the messages and further things
>  >  to check.
>
>  Ok
>
>
>  >
>  >  Firstly, regarding the `BUG' message: it is part of the initial feature
>  >  negotiation (during 3-way handshake). The "state 2" means FEAT_CHANGING,
>  >  a  Change option was sent but not confirmed.
>  >  The good thing of having a stack trace is that we know that this
>  >  happened on the server,
>
>  Yes, in fact.
>
>
>  > in dccp_create_openreq_child. It would be next
>  >  to ideal to have a tcpdump of the scenario, but on paper this looks like:
>  >   * client is in PARTOPEN (has sent Ack, awaits packet from server);
>  >   * server is in RESPOND and about to move to OPEN;
>  >   * client has sent the Ack confirming the options requested by the
>  >    server;
>  >   * the server complains that one of the options it has asked for was
>  >    not confirmed.
>  >  Can you confirm that both end hosts really had identical DCCP versions?
>  >
>
>  Yes, the same version of DCCP. I repeated the same scenario and this
>  situation didn't happened anymore
>
>
>  >  In the log I see that there were several large burst losses plus one
>  >  occurrence of `invalid' checksum. Is this a very lossy link - if the
>  >  DCCP-Request/Response/Ack got retransmitted, the feature-negotiation
>  >  options would in theory also be retransmitted, so that would not matter.
>  >
>
>  I'm using one end connected to a wifi 802.11g access point and the
>  other connected via ethernet in this same access point. The ethernet
>  point is the server, the wifi point, the client.
>
>
>  >  Individual information to the messages is below.
>  >
>  >
>  >  | [ 3128.785764] dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
>  >  <snip>
>  >  The "Not changing Ack Ratio" message are harmless, they are just a
>  >  reminder that, due to still unresolved problems in CCID-2, dynamic
>  >  switch of Ack Ratio is currently disabled: Ack Ratio is currently always
>  >  1, no matter the messages (net/dccp/minisocks.c).
>  >
>  >
>  >  | [ 4510.339903] dccp_v4_rcv: dropped packet with invalid checksum
>  >  Checksum failure is extremely rare -- are you using a wireless link?
>  >
>
>  Yes, wireless link.
>
>
>  >
>  >
>  >  | [ 4852.431819] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
>  >  This message can also be ignored due to the earlier comment; when using
>  >  dynamic Ack Ratios this would avoid persistent spurious RTO timeouts.
>  >
>  >
>  >
>  >
>  >  | [ 5467.093407] e1000: eth0: e1000_watchdog: NIC Link is Down
>  >  | [ 5470.228254] e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps
>  >  | Full Duplex, Flow Control: RX/TX
>  >  Was traffic sent over eth0? If yes, then it may have relevance for the
>  >  bug, for if the cable is disconnected in the middle of a connection,
>  >  the situation changes.
>  >
>
>  I don't know what happened in this moment, since nobody unplug the cable, AFAIK.
>
>
>  >
>  >
>  >  | [ 4853.013621] dccp_ackvec_add_new: Warning: large burst loss (583)
>  >
>  > | [ 5690.125731] dccp_ackvec_add_new: Warning: large burst loss (943)
>  >
>  > | [ 5747.246785] dccp_ackvec_add_new: Warning: large burst loss (76)
>  >
>  > | [ 6301.420651] dccp_ackvec_add_new: Warning: large burst loss (77)
>  >  I have collated these messages - there is quite a lot of loss going on
>  >  and I am wondering whether the Ack Vectors are properly dimensioned.
>
>  Hum... this is one thing to check. For my situation (wifi and ethernet
>  link), what do you suggest to use. To properly dimension Ack vectors,
>  do I need just to set the parameters like that?:
>
>  sudo sysctl -w net.dccp.default.seq_window000
>  sudo sysctl -w net.dccp.default.send_ackvec=1
>
>
>  >  This is independent of the bug report: in any case, the warning message
>  >  says that multiple losses will now be compressed into cells of 63 lost
>  >  packets each, instead of occupying one cell each (which would otherwise
>  >  almost certainly lead to overflow).
>  >
>  >  Back to the bug report:
>  >
>  >
>  >  | [ 6286.655846] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
>  >  | [ 6286.864021] BUG: Failed negotiation in state 2 at
>  >  | net/dccp/feat.c:1370/dccp_feat_activate_values()
>  >  | [ 6286.864034] Pid: 0, comm: swapper Not tainted 2.6.25-rc3 #4
>  >  | [ 6286.864034]  [<c045c6bb>] dccp_feat_activate_values+0x7b/0x200
>  >  | [ 6286.864034]  [<c045f919>] dccp_create_openreq_child+0xb9/0x100
>  >  <snip>
>  >
>  > | [ 6288.714624] ccid2_change_l_ack_ratio: Limiting Ack Ratio (4) to 2
>  >  The "Limiting Ack Ratio (4) to 2" must be from a different flow, since
>  >  it was before the BUG message and continued afterwards.
>
>  Probably, I setup iperf with -P 3 for DCCP
>
>
>  >
>  >  Now I see what you meant by `stopped': if feature negotiation fails,
>  >  the thread indeed stops, since otherwise it would mean to operate
>  >  with an undefined (unconfirmed) option value, which will otherwise
>  >  cause havoc. The server ends the connection with a reset (can you
>  >  remember what the client reported after that?).
>
>  I didn't check the client side log! :(
>
>
>  >
>  >  It is a pity that you don't have the tcpdump, this would allow to find
>  >  out which feature option could not be negotiated.
>
>  I'm sorry about that! :(
>
>
>  >
>  >  What I will do for the moment is to turn the dccp_pr_debug() under
>  >  the `activation_failed' into a DCCP_CRIT, so that it outputs the type
>  >  of the feature that has failed.
>
>  That's a good idea!
>
>
>
>  >
>  >  Please check the above questions.
>  >
>  >  Gerrit
>  >
>
>  Leandro.
>

Just to inform:

sysctl -w net.dccp.default.send_ackvec=1
error: "net.dccp.default.send_ackvec" is an unknown key

I remember that you removed this option in the kernel. In this case I
will update the DCCP wiki, ok?

Leandro.
