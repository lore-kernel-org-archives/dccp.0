From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Nov 2006 15:58:59 +0000
Subject: Re: [BUG] CCID3 no longer works!
Message-Id: <200611301558.59413@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611291504v60e06067h469e8c91293031c9@mail.gmail.com>
In-Reply-To: <5640c7e00611291504v60e06067h469e8c91293031c9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian McDonald wrote:
|  Folks,
|  
|  I've started my testing and confirm what the other two have said on
|  list. Using Acme net 2.6.20 tree as of about four hours ago basically
|  I get no data transmitted. Works fine on my 2.6.19 modified tree.
|  
|  I'm using iperf as follows (using today's iperf patch)
|  ian@jandi3:~$ iperf --protocol dccp -s -l 500
|  ian@jandi1:~$ iperf --protocol dccp -c jandi3 -l 500 -t 20
|  
|  There are some clues at least on jandi3 log:
|  Nov 30 11:57:49 localhost kernel: [  645.677995]
|  ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
|  sent
|  Nov 30 11:57:49 localhost kernel: [  645.678678]
|  ccid3_hc_tx_packet_recv: Illegal ACK received - no packet has been
|  sent
|
Many thanks for supplying the up-to-date iperf, it makes testing so much easier.
After I had found that bug (see patch), I had

$ iperf-2.0.2iperf --protocol dccp -s -l 1424
------------------------------------------------------------
Server listening on DCCP port 5001
 (default)
------------------------------------------------------------
[  4] local 139.133.209.176 port 5001 connected with 139.234.123.65 port 32911
[  4]  0.0- 9.7 sec  74.3 MBytes  64.2 Mbits/sec


Relief :-) !!

I could not trigger the bug you mention above. Are you using the standard davem kernel?
If yes, further tests are necessary.
