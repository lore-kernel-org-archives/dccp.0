From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 04 Jan 2011 11:42:49 +0000
Subject: Re: Sequence Number Validation Bug Fixes 0/2
Message-Id: <20110104114249.GA3566@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1293392426.3801.234.camel@jero-laptop>
In-Reply-To: <1293392426.3801.234.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > With regard to not updating the Ack Number, I remember having seen something
| > related earlier. There is a relationship between the current sending rate, the
| > Ack Ratio, the cwnd, and the Sequence Window. The Ack window is advanced by the
| > GSS and depends on the local value of the Sequence Window. RFC 4340, 7.5.2
| > recommends 5 * max_packets_per_RTT as guideline for Sequence Window.
| > 
| > When I looked at this earlier I noted that the dynamic update of Ack Ratio,
| > cwnd, and Sequence Window (which are all inter-related, but are controlled
| > by different code paths) does not produce the expected interaction, therefore
| > Ack Ratio is currently always 1 and Sequence Window is also static and does
| > not change throughout the connection. 
| > 
| > It may be that both these shortcuts cause the behaviour you observed. The
| > Ack Ratio update is disabled in net/dccp/feat.c:dccp_hdlr_ack_ratio(), but
| > there is currently no code to predict (guess) what the sending rate will
| > be for the next 5 RTTs -- if such a heuristic is possible.
| 
| Interesting, but I don't think that's what I'm seeing.
| 
| What I'm noticing is that the DCCP sender doesn't update it's ack
| numbers very often. In examining packet captures, it is typical for DCCP
| to send 20-60 packets with the same ack number (If I increase the ack
| and seq validity windows to 1000, I've seen 200 packets with the same
| ack number).
| 
Depending on the type of link (duplex or half-duplex as in WiFi) and the 
application sending rate, this might even be normal.

In 7.5.2, it is suggested to set the Sequence Window to 5 * packets/RTT where
packets/RTT is the expected maximum number of packets to be sent in one RTT. If
the Sequence Window value is very much larger than this guideline, it could be
that there are no big chances in the acknowledgment number.

But this is only a guess - I think it requires to spend some time with your
tool and/or wireshark traces to see what is going on.


| Since the receiver should ack every packet it gets, I would think that
| we should see very few packets (1-2) sent before a new ack packet comes
| and updates the GSR and hence the outgoing packet's ack numbers.
| 
I think this implicitly refers to cwnd/pipe in CCID-2 which take care of the
window flow control. There is a relationship between cwnd and Ack Ratio (there
are already some comments in ccid2_change_l_ack_ratio, which resulted from
earlier tests which showed that Ack Ratio and cwnd have a relationship.

Since cwnd and rtt determine packets/RTT, this should also allow to derive the
right value for Sequence Window. But this has not been worked out satisfactorily
yet, there is indeed room for more work here.

| Some debugging output (printk at every send and receive) seems to
| indicate that the sending and receiving are happening in large chunks
| and not in small slices (we send 50 packets, then receive 20 packets,
| etc).
| 
Nowadays multiple packets are serviced per interrupt. I have seen similar things
in CCID-3, but these things seem to depend on the link-layer and perhaps also
the network driver, comparing different configurations helps.
