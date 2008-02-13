From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 13 Feb 2008 14:42:53 +0000
Subject: Re: [iperf]: Bug fixes in DCCP support
Message-Id: <20080213144253.GA28676@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080211113044.GA1609@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080211113044.GA1609@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| 
| Good news Gerrit, but in details of changes you mentioned this:
| 
| * enabled UDP-like reporting of statistics also for DCCP;
| 
| But according to my tests, I had this for UDP
| 
| ------------------------------------------------------------
| Server listening on UDP port 5001
| Receiving 1470 byte datagrams
| UDP datagram buffer size:  105 KByte (default)
| ------------------------------------------------------------
| [  3] local 127.0.0.1 port 5001 connected with 127.0.0.1 port 48341
| [  3]  0.0- 1.0 sec   129 KBytes  1.06 Mbits/sec   0.007 ms    0/   90 (0%)
| [  3]  1.0- 2.0 sec   128 KBytes  1.05 Mbits/sec   0.006 ms    0/   89 (0%)
| (...)
| 
| and for DCCP
| 
| ------------------------------------------------------------
| Server listening on DCCP port 5001
| NOTE: running in bytestream-mode (maximum speed)
| DCCP datagram buffer size:  105 KByte (default)
| ------------------------------------------------------------
| [  4] local 127.0.0.1 port 5001 connected with 127.0.0.1 port 45839
| [  4]  0.0- 1.0 sec  56.7 MBytes   476 Mbits/sec
| [  4]  1.0- 2.0 sec  57.1 MBytes   479 Mbits/sec
| [  4]  2.0- 3.0 sec  57.0 MBytes   478 Mbits/sec
| [  4]  3.0- 4.0 sec  56.9 MBytes   477 Mbits/sec
| 
| 
| What is different for the previous version of your patches?
| 
Note the `NOTE' message: you are using in bytestream mode 
(see http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/#iperf )

To use packet-oriented mode, use the `-b' option.

The use is as in UDP: without argument, a default CBR of 1 Mbps is used.
Otherwise, the argument is CBR in bps (m=Mbps, k=kbps).
In the above, try e.g. -b450m for 450Mbps.

Make sure you use it on both server and client.
