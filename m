From: Schier Michael <michael.schier@uibk.ac.at>
Date: Wed, 30 Sep 2009 21:57:04 +0000
Subject: sendbuffer-size controls (non)blocking behaviour? ccid3 throughput
Message-Id: <4AC3D430.7050409@uibk.ac.at>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi all,

I'm doing some experiments over DCCP (Ubuntu kernel version 2.6.28-15) using CCID3. The following is
a list of things which confused me a bit. Maybe someone can give me an explanation...
All mentioned files in the following text can be found at http://138.232.66.193/public/.

In all scenarios, I have a sender(A) and a receiver(C) application. Both half-connections use CCID3.
The sender transmits at full speed, the other half-connection isn't used. (shutdown(socket,SHUT_RD)
is called at the sender). Between A and C, I have another computer (B) and i applied tc qdisc add
dev ethx root tbf rate 40kbit burst 10kb limit 10kb

1) I usually abort the sender with Ctrl+C. The sender sends a Close, the receiver immediately
answers with CloseReq. Then the sender agains sends a Close and repeats this after 6 seconds and
again after another 12 seconds. Then again the receiver sends a CloseReq and the sender returns
Close (and so on). And no, I haven't forgotten the receiver-side close(socket) call.
The receiver processed incoming connections in a while loop (one bin and listen call at the
beginning of the program, several accept and recv calls in the loop). From time to time, it happens
that I cannot establish a connection to the same port again and get the error "Too many users". The
receiver answer with a Reset packet, code "too busy". After several minutes, the port can be reused
again. after_application_end.* is a packet dump performed at B after doing some tests on various ports.

2) I send data packets with payload size 1000 bytes. When I choose a send buffer size <= 4976 bytes,
the send call is blocking as expected (setsockopt(socket, SOL_SOCKET, SO_SNDBUF, ...). By increasing
the send buffer by at least 1 byte, the socket is non-blocking. It returns EAGAIN until we are
allowed to send a new packet.

3) Can I control the blocking/nonblocking behavior somehow? (e.g. using ioctl FIONBIO or O_NONBLOCK)

4) I also observed some strange behaviour here: I use tc qdisc add dev ethx root netem delay 50ms.
50ms_noloss.jpg depicts the throughput. Why are there these periodic drops? There isn't any packet loss.

5) I modified the scenario from point 4 and caused a single packet loss ~ at second 8,5
(50ms_singleloss.jpg). By using
getsockopt with DCCP_SOCKOPT_CCID_TX_INFO, I see that p (packet loss rate) gets a nonzero value,
which then decreases down to 0.01% but not further. Unfortunately, the connection can only reach a
1/5 of the throughput before the packet drop. I know that the theoretic bandwidth utilization
depends on the bandwidth delay product, but is a rtt of 50ms such a dramatically high value??


cheers,
mike

-----------------------
Michael Schier
PhD Student
University of Innsbruck
Austria
