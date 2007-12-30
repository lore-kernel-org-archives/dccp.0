From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 30 Dec 2007 15:18:36 +0000
Subject: Re: panic on 2.6.24rc5
Message-Id: <200712301618.36350.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Friday 28 December 2007, I wrote:
> Dnia Wednesday 26 of December 2007, napisa=B3e=B6:
> > What are the panics you are getting? It might be worth posting them to
> > the list.
>
> Here is the screenshot I captured a few days ago. Details:
>  - kernel-vanilla 2.6.24rc5,
Now I'm using kernel as described in Arnaldo's mail (davem/net-2.6.25 +=20
patches 0001 to 0051).

>  - netem+tbf limited traffic on lo interface,
>  - the panic was preceeded by several dmesg entries like that:
When netem is not used used there are no BUG entries in dmesg, if it is I g=
et:
BUG: err=3D1 after ccid_hc_tx_packet_sent=20
at /home/users/tomek/samba/dccp_exp/output.c:284/dccp_write_xmit()
Pid: 1745, comm: sclient Not tainted 2.6.24_vanilla-0.1smp #1
 [<e08afe4a>] dccp_write_xmit+0x14a/0x220 [dccp]
 [<e08b26f0>] dccp_write_xmit_timer+0x0/0x50 [dccp]
 [<e08b2739>] dccp_write_xmit_timer+0x49/0x50 [dccp]
 [<c013519b>] run_timer_softirq+0xbb/0x190
 [<c0143691>] hrtimer_interrupt+0x131/0x1e0
 [<c0130ec4>] __do_softirq+0xd4/0xf0
 [<c0130f18>] do_softirq+0x38/0x40
 [<c0130fc5>] irq_exit+0x75/0x80
 [<c0117c4a>] smp_apic_timer_interrupt+0x2a/0x40
 [<c0104c64>] apic_timer_interrupt+0x28/0x30
 [<c030c648>] _spin_unlock_irqrestore+0x8/0x10
 [<c025f5de>] n_tty_receive_buf+0x20e/0xaf0
 [<c01403f0>] autoremove_wake_function+0x0/0x50
 [<c016704a>] prep_new_page+0xca/0x120
 [<c0294dd4>] sys_sendto+0xc4/0xf0
 [<c0261c15>] pty_write+0x45/0x50
 [<c025edaf>] opost_block+0x7f/0x110
 [<c0260aed>] write_chan+0x18d/0x220
 [<c0125da0>] default_wake_function+0x0/0x10
 [<c0142b30>] lock_hrtimer_base+0x20/0x50
 [<c0125da0>] default_wake_function+0x0/0x10
 [<c025bde5>] tty_write+0x185/0x1f0
 [<c01439f1>] hrtimer_nanosleep+0x41/0xc0
 [<c0260960>] write_chan+0x0/0x220
 [<c0185acf>] vfs_write+0xbf/0x150
 [<c0185c27>] sys_write+0x47/0x80
 [<c0104196>] sysenter_past_esp+0x5f/0x85
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>  - dccp seemed to be painfully slow at sending packets from queue (but I
> have no numbers to prove that),
Ok, now I do have numbers. I wrote a program (sclient) which sends an 80 by=
te=20
packet every 100ms. Here are the times of arrival (ie. time(0)) on the othe=
r=20
end of the connection (note that this is on loopback interface with no=20
limiting):
1199023603
1199023603
1199023603
1199023603
1199023604
1199023604
1199023604
1199023604
1199023604
1199023604
1199023604
1199023604
1199023604
1199023604
1199023605
1199023605
1199023605
1199023605
1199023605
1199023605
1199023605
1199023605
1199023605
1199023605
1199023606
1199023606
1199023606
1199023606
1199023606
1199023606
1199023606
1199023606
1199023606
1199023606
1199023607
1199023607
1199023607
1199023607
1199023607
1199023608
1199023608
1199023609
1199023610
1199023613
1199023615
1199023619
1199023624
1199023633
1199023642
1199023659
1199023677
1199023713
1199023749
1199023813
1199023877
1199023941
1199024005
1199024069
1199024133
1199024197
1199024261
1199024325

during this time I get 4 lines in dmesg:
dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 0
dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 2
dccp_hdlr_ack_ratio: Not changing RX Ack Ratio from 1 to 2
dccp_hdlr_ack_ratio: Not changing TX Ack Ratio from 1 to 0

As you can see for the first few seconds all is fine (packets arrive 9-10 a=
=20
second), but then the speed drops to 1 packet every 64 seconds. Can anybody=
=20
reproduce that? Or what may I be doing wrong?

>  - the crash is pretty much reproducible.
The crash seems to be gone. But for me dccp is still unusable...
--=20
Regards,
Tomasz Grobelny
