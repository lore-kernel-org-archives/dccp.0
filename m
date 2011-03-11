From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 11 Mar 2011 11:30:17 +0000
Subject: Re: [Patch 1/1] dccp: CCID2 increment cwnd correctly
Message-Id: <20110311113017.GA4876@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1299562278.7569.82.camel@jero-laptop>
In-Reply-To: <1299562278.7569.82.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| However, in slow start CCID2 performs this test to increment cwnd every
| second ack:
| ++hc->tx_packets_acked =3D 2
| Unfortunately, this will be incorrect, if cwnd previous to the idle
| period was larger than 2 and if tx_packets_acked was close to cwnd. For
| example: cwndP and tx_packets_ackedE.
|=20
| In this case, the current code, will increment tx_packets_acked until it
| equals two, which will only be once tx_packets_acked (an unsigned 32bit
| int) overflows.
|=20
| My fix is simply to change that test for tx_packets_acked greater than
| or equal to two in slow start.
|=20
Excellent catch, thank you very much. This has also been added to the test =
tree.

Would you be ok with me reusing the commit message as a comment - or if you
like, you can also send an update.

http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;h=F7095cb6dc9b85adb42c23c22b8938589c9965e8
