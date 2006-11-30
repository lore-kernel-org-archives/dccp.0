From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Nov 2006 22:25:07 +0000
Subject: [BUG] CCID3 performance is f**ked
Message-Id: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Folks,

CCID3 is fucked up. Sorry to put it this way but thats how I feel.

With 2.6.19rc6 plus the patches from
http://wand.net.nz/~iam4/dccp/patches/ it works fine. (The only
significant patch here is tx_qlen - all the rest should have no
impact).

So here are the stats using iperf:
Test                                             2.6.19rc6+ian
2.6.20-acme20
Direct connect                                87 Mbits             36 Mbits
Through a Linux router (1.2 ms rtt)    36 Mbit               200 kbits
(yes that is correct!)
Through netem (100 ms rtt, 5% loss)  130 kbits           116 kbits (OK)

So somewhere on low rtt links we've stuffed up.

Below is the logs from the receiver from when performance dropped from
36 Mbit to 200 kbits. The illegal ACKs are documented in another email
and I don't think are the problem. The issue I suspect is that it says
rtt is around 12000 usecs which is 12 msec and it is really 1.2
msecs....

I can't look at this for a while as have to go to work and have my
kids over this weekend. I'll start bisecting next week if I can if
nobody else has fixed.

Can I suggest that people test CCID3 on a range of loss, rtt
combinations please? CCID3 has proven time after time to be very
sensitive....

Dec  1 10:59:33 localhost kernel: [  292.691727] CCID: Registered CCID 3 (c=
cid3)
Dec  1 10:59:35 localhost kernel: [  294.849298] ccid3_hc_rx_init:
undefined, sk=D93d44f4
Dec  1 10:59:46 localhost kernel: [  305.502410] ccid3_hc_rx_init:
server, sk=D93d402c
Dec  1 10:59:46 localhost kernel: [  305.503569]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Dec  1 10:59:46 localhost kernel: [  305.503899]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), skb=D8d5ca54,
sending initial feedback
Dec  1 10:59:46 localhost kernel: [  305.503910]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 10:59:46 localhost kernel: [  305.503988]
ccid3_hc_rx_set_state: server(d93d402c) NO_DATA  -> DATA
Dec  1 10:59:46 localhost kernel: [  305.504304]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Dec  1 10:59:47 localhost kernel: [  306.540524]
ccid3_hc_rx_packet_recv: server, New RTT=8319us, elapsed time=99893
Dec  1 10:59:47 localhost kernel: [  306.540548]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 10:59:47 localhost kernel: [  306.540757]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Dec  1 10:59:47 localhost kernel: [  306.549141]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 10:59:47 localhost kernel: [  306.557618]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 10:59:47 localhost kernel: [  306.586727]
ccid3_hc_rx_calc_first_li: server, sk=D93d402c, approximated RTT to
10139us
Dec  1 10:59:47 localhost kernel: [  306.586751]
ccid3_hc_rx_calc_first_li: server, sk=D93d402c, receive rate%7554
bytes/s, implied loss rate1600
Dec  1 10:59:47 localhost kernel: [  306.587435]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:47 localhost kernel: [  306.587445]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 10:59:47 localhost kernel: [  306.587631]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:47 localhost kernel: [  306.587695]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting... Dec  1 10:59:47 localhost kernel: [  306.587736]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 10:59:47 localhost kernel: [  306.590319]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:47 localhost kernel: [  306.591652]
ccid3_hc_rx_packet_recv: server, New RTT=12590us, elapsed time=3D6
Dec  1 10:59:47 localhost kernel: [  306.591705]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Dec  1 10:59:47 localhost kernel: [  306.592173]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:47 localhost kernel: [  306.593686]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:47 localhost kernel: [  306.596084]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:47 localhost kernel: [  306.598884]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:47 localhost kernel: [  306.600443]
ccid3_hc_rx_send_feedback: server, sk=D93d402c Dec  1 10:59:53
localhost kernel: [  312.721806] ccid3_hc_rx_packet_recv: server, New
RTT=11494us, elapsed timea2297
Dec  1 10:59:53 localhost kernel: [  312.722044]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:53 localhost kernel: [  312.722055]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 10:59:53 localhost kernel: [  312.722235]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Dec  1 10:59:59 localhost kernel: [  318.888455]
ccid3_hc_rx_packet_recv: server, New RTT=13965us, elapsed timea3345
Dec  1 10:59:59 localhost kernel: [  318.888498]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:59 localhost kernel: [  318.888514]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Dec  1 10:59:59 localhost kernel: [  318.888736]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 10:59:59 localhost kernel: [  318.889106]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 10:59:59 localhost kernel: [  318.903541]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 11:00:06 localhost kernel: [  325.881546]
ccid3_hc_rx_packet_recv: server, New RTT=12734us, elapsed timei8005
Dec  1 11:00:06 localhost kernel: [  325.881726]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 11:00:06 localhost kernel: [  325.881741]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Dec  1 11:00:13 localhost kernel: [  332.891106]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 11:00:30 localhost kernel: [  349.250143]
ccid3_hc_rx_packet_recv: server, sk=D93d402c(OPEN), data loss!
Reacting...
Dec  1 11:00:46 localhost kernel: [  365.608751]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 11:01:03 localhost kernel: [  381.966677]
ccid3_hc_rx_packet_recv: server, New RTT=11696us, elapsed time=1636430
Dec  1 11:01:03 localhost kernel: [  381.966715]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 11:01:03 localhost kernel: [  381.966896]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Dec  1 11:01:08 localhost kernel: [  387.419224]
ccid3_hc_rx_packet_recv: server, New RTT=10691us, elapsed timeT5374
Dec  1 11:01:08 localhost kernel: [  387.419250]
ccid3_hc_rx_send_feedback: server, sk=D93d402c
Dec  1 11:01:08 localhost kernel: [  387.419417]
ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
sent
Dec  1 11:01:08 localhost kernel: [  387.422031]
ccid3_hc_rx_set_state: server(d93d402c) DATA     -> TERM
Dec  1 11:01:08 localhost kernel: [  387.422066]
ccid3_hc_tx_set_state: server(d93d402c) NO_SENT  -> TERM

Ian
--=20
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
