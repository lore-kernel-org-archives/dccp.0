From: "patrick andrieux" <patrick.andrieux@gmail.com>
Date: Mon, 23 Apr 2007 10:26:42 +0000
Subject: RTT computation in struct tfrc_rx_info
Message-Id: <fca78b970704230326i12e8cb15w3e4aa4a114214993@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi list,

I developed a basic client/server program, with bidirectional communication.
Basically, server accept connection from a client and they send
packets to them for a few time every 20milliseconds.
I printed out tfrc_rx_info RTT values in a file in order to get a graph.

What I get is a graph who starts from 0 and converge to the same RTT value.
So this seems pretty bad to me, and I wanted to share that with you,
dccp developers. I guess you are probably aware of that, I just trying
to figure out what's happening in the receive struct.

An other point is, if I only stop sending without closing socket,
(that means my application blocks on "read" or something like this),
when I restart the sending, RTT is completely false. It could be 23000
microseconds or 40000 microseconds instead of 300us or 400us, and it
converges again to the same value.

Is it something I would have to expect since dccp is in development?

Just to be clear I'm talking about RTT in tfrc_rx_info structure, not
in tfrc_tx_info which looks fine to me.
I'm using the latest dave Miller's tree 2.6.21-rc7 on Debian testing.


Best regards,
Patrick.
