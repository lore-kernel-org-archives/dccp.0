From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Jan 2008 13:41:17 +0000
Subject: Re: panic on 2.6.24rc5
Message-Id: <20080107134117.GE6976@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


Quoting Tomasz Grobelny:
| On Friday 28 December 2007, I wrote:
| > Dnia Wednesday 26 of December 2007, napisa?e?:
| > > What are the panics you are getting? It might be worth posting them to
| > > the list.
| >
| > Here is the screenshot I captured a few days ago. Details:
| >  - kernel-vanilla 2.6.24rc5,
| Now I'm using kernel as described in Arnaldo's mail (davem/net-2.6.25 + 
| patches 0001 to 0051).
| 
| >  - netem+tbf limited traffic on lo interface,
| >  - the panic was preceeded by several dmesg entries like that:
| When netem is not used used there are no BUG entries in dmesg, if it is I get:
| BUG: err=1 after ccid_hc_tx_packet_sent 
The `err' refers to the return value of dccp_transmit_skb(), the
corresponding errno number is in include/asm-generic/errno-base.h

#define EPERM            1      /* Operation not permitted */

Are you running a security Linux (selinux) or as non-root?

| 
| >  - dccp seemed to be painfully slow at sending packets from queue (but I
| > have no numbers to prove that),
| Ok, now I do have numbers. I wrote a program (sclient) which sends an 80 byte 
| packet every 100ms. Here are the times of arrival (ie. time(0)) on the other 
| end of the connection (note that this is on loopback interface with no 
| limiting):
| 1199023603
| 1199023603
| 1199023603
| 1199023603
| 1199023604
| 1199023604
| 1199023604
| 1199023604
| 1199023604
| 1199023604
| 1199023604
| 1199023604
| 1199023604
| 1199023604
| 1199023605
| 1199023605
| 1199023605
| 1199023605
| 1199023605
| 1199023605
| 1199023605
| 1199023605
| 1199023605
| 1199023605
| 1199023606
| 1199023606
| 1199023606
| 1199023606
| 1199023606
| 1199023606
| 1199023606
| 1199023606
| 1199023606
| 1199023606
| 1199023607
| 1199023607
| 1199023607
| 1199023607
| 1199023607
| 1199023608
| 1199023608
| 1199023609
| 1199023610
| 1199023613
| 1199023615
| 1199023619
| 1199023624
| 1199023633
| 1199023642
| 1199023659
| 1199023677
| 1199023713
| 1199023749
| 1199023813
| 1199023877
| 1199023941
| 1199024005
| 1199024069
| 1199024133
| 1199024197
| 1199024261
| 1199024325
| 
| during this time I get 4 lines in dmesg:
| dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 0
| dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
| dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
| dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0
| 
Did you set net.dccp.default.ack_ratio=1 ? It looks like it. In any
case, this output looks good, since
 * the CCID3 sender disables Ack Ratio (Ack Ratio is only used by CCID2)
 * since you are using loopback, you get both sender/receiver messages
   (i.e. one sender message is always paired with one receiver message)
 * the CCID3 receiver does not touch Ack Ratio and leaves it at the default
   value for Ack Ratio (2)
 * the "Not changing {R,T}X Ack Ratio" messages are due to the fact that
   the Ack Ratio handler is currently disabled. This is a precaution
   since CCID2 is not well-behaved yet with Ack Ratios different from 1
 * the Ack Ratio messages should in general not affect CCID3 performance
   since the CCID3 code ignores Ack Ratio (i.e. they are only informative)

| As you can see for the first few seconds all is fine (packets arrive 9-10 a 
| second), but then the speed drops to 1 packet every 64 seconds. Can anybody 
| reproduce that? Or what may I be doing wrong?
I will also try the setting you described. Is it possible for you to run
your program between two computers (on testbeds here it works ok)?
The 64 seconds means that CCID3 is dying very badly; 64 seconds is the
maximum packet delay (t_mbi in RFC 3448), so there is something really
strange going on. In combination with the -EPERM error it may be that
the loss rate is very very hight.

We would really be grateful for any further hints that you could give us.

Here are a few more things to test
 * you can see your setting in the Request/Response handshake, the set
   of features negotiated for the connection is in the Response
  
 * many CCID3 parameters are printed out in dccp_probe, but I don't know
   how well this works when using loopback. Some scripts are on
   http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/

 * wireshark (source version) is also able to decode the receiver reports
   by the CCID3 receiver (X_recv/loss p)
