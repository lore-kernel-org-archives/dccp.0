From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Thu, 06 Mar 2008 20:57:27 +0000
Subject: Re: panic on 2.6.24rc5
Message-Id: <200803062157.28108.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Tuesday 01 of January 2008, Arnaldo Carvalho de Melo napisa=C5=82:
> Could you do this at and report the results?
Ok, back to the old thread. I found out that commit after which dccp over=20
loopback (no limiting) has huge delays (as reported previously) is=20
52515e77a7a69867c479db4c9efb6be832b82179. This is for CCID3 only no matter =
if=20
client and server programs are run by root or not. dmesg shows:
CCID: Registered CCID 3 (TCP-Friendly Rate Control)
dccp_sample_rtt: unusable RTT sample -172, using min
ccid3_hc_tx_packet_recv: client(cfb52740): ACK with bogus ACK-1257737462649=
29

Please feel free to ask for more info. Now I should have more time to test =
and=20
make experiments.
--=20
Regards,
Tomasz Grobelny
