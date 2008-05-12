From: "Roksana Boreli" <Roksana.Boreli@nicta.com.au>
Date: Mon, 12 May 2008 08:58:39 +0000
Subject: CCID4 Testing - bug fix
Message-Id: <09D3F703EF3B0A4CBE28449EA9F3D32009EB46E6@nicta-atp-mail.in.nicta.com.au>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,

We have tested the CCID4 implementation kernel version 2.6.25-rev8 with
representative VoIP data streams and uncovered what we believe to be a
bug in the implementation. 

The bug relates to slow start and transition from slow start to
congestion control.  The following page 
http://203.143.173.13/dccp_at_nicta/ccid4/bug.html  shows the results
for the unpatched and patched code. Shown is captured data rate at the
receiver, with a 1Mbit/s link and 200msec delay using netem: (a) with
the original DCCP-CCID4 code; (b)with patched DCCP-CCID4 code. 
We use iperf with 8kbit/s CBR and 20b packets, which represents data at
the output of a G.729 codec, have done tests with higher rates too. 

Patch details: we modify the sender rate in the initial phase when
congestion control is not yet applied. In the original code, the header
penalty rate reduction of s/(s+overhead) was, I believe, incorrectly
applied to all sender rates. My understanding of the
draft-ietf-dccp-ccid4-02.txt is that the header penalty should only be
applied in the congestion control phase, in which the fixed packets
(1460 b) are used in place of the average packet size s. Otherwise you
eventually throttle the rate to a very low rate as the growth governed
by min(2*X, 2*Xrec) cannot work when the header penalty is less than 0.5
- in this case you shrink rather than grow. 

Example: header penalty for a 20b packet is 20/56=0.357. On RTT of
200msec, the initial rate is 3.2kbit/s, assuming the receiver gets this
rate, you grow to 2*Xrec*header penalty, which is 2.28kbit/s, etc till
you reach the min rate of s/RTT.

The congestion control phase works fine, also the capping of packet
rate.

Is it possible to contribute to the ccid4 tree, or (for Gerrit) would
you like us to send you the patch which is not a large number of lines. 

Kind regards, Roksana


Dr Roksana Boreli
Principal Research Engineer
NICTA | Locked Bag 9013 | Alexandria NSW 1435
T +61 2 8374 5507 | F +61 2 8374 5579  
www.nicta.com.au  
From imagination to impact

-----Original Message-----
From: dccp-owner@vger.kernel.org [mailto:dccp-owner@vger.kernel.org] On
Behalf Of Gerrit Renker
Sent: Thursday, 6 December 2007 7:07 PM
To: dccp@vger.kernel.org
Subject: CCID4 Testing - Some Results

Below are some test results with the latest CCID4 subtree; two tests
were performed:

 (a) iperf throughput tests
 (b) audio streaming using paraslash.

Both tests were performed using DCCPv6 only, so DCCPv4 supposedly works
also.


1. iperf throughput testing
---------------------------
To make iperf accept IPv6 addresses, the -V option had to be passed to
the program; below are the results of running between two hosts
connected via a 100Mbps (crossover) LAN:

          +--------+-------------------+--------------------+
          |  `s'   |  iperf throughput | packets per second |
          +--------+-------------------+--------------------+
          |   16b  |  12.6 kbps        |      98.43         |
          |   32b  |  25.1 kbps        |      98.05         |
          |   64b  |  50.3 kbps        |      98.24         |
          |  128b  | 101.0 kbps        |      98.63         |
          |  256b  | 201.0 kbps        |      98.14         |
          |  512b  | 402.0 kbps        |      98.14         |
          | 1024b  | 805.0 kbps        |      98.27         |
          | 1420b  | 1.12 Mbps         |      98.60         |
          +--------+-------------------+--------------------+

The tests were run over DCCPv6 only which is why the highest MPS is 1420
bytes (Ethernet; with minimum set of features the MPS is 1440 for v4 and
1420 for v6).

It is noticeable that CCID4 uses a built-in speed-limiter: the
packets-per-second speed is the same in each case (the value is only
approximate, the column simply shows throughput / (8 * s), one would
want to take IPv6/DCCP header sizes into the calculation as well; not
done here).

So in this regard CCID4 behaves like CCID3: when there is no loss, it
quickly climbs up to link speed, or rather maximum the speed limit.

How the results were obtained: when iperf is used without the `-b'
option, it
                               completely tries to overrun the socket
with data,
                               so for all packet sizes less than 1420
bytes,
                               the -b switch was set to the default
value (1 Mbps);
                               for 1420b it was set to `-5m' which
corresponds to a
                               constant bitrate of 5Mbps.


2. Audio streaming using paraslash
----------------------------------
CCID4 was set as default CCID using the {rx,tx}_ccid sysctls and a
longer (50 min) MP3 file was streamed from server to client. It is a
less boring setup than iperf, since when there is a problem, it will
become audible very quickly.

When doing the MP3-streaming, I had on DCCPv6
 * average packet size: 160 bytes
 * and the X_recv observed in the DCCP-Acks was
   frequently set to 6042 bytes/sec
 * which corresponds to ~ 48kbps, which is in agreement with the above
table
 * and it also agrees perfectly with the encoding of the MP3 file -- its
   header says that it was encoded for 48 kbps joint-stereo and I think
   that means constant bitrate since VBR in MP3 is a bit more complex.

Gerrit   
-
To unsubscribe from this list: send the line "unsubscribe dccp" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html

