From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 06 Dec 2007 08:07:22 +0000
Subject: CCID4 Testing - Some Results
Message-Id: <20071206080722.GB6804@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Below are some test results with the latest CCID4 subtree; two tests were performed:

 (a) iperf throughput tests
 (b) audio streaming using paraslash.

Both tests were performed using DCCPv6 only, so DCCPv4 supposedly works also.


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

The tests were run over DCCPv6 only which is why the highest MPS is 1420 bytes
(Ethernet; with minimum set of features the MPS is 1440 for v4 and 1420 for v6).

It is noticeable that CCID4 uses a built-in speed-limiter: the packets-per-second
speed is the same in each case (the value is only approximate, the column simply
shows throughput / (8 * s), one would want to take IPv6/DCCP header sizes into
the calculation as well; not done here).

So in this regard CCID4 behaves like CCID3: when there is no loss, it quickly
climbs up to link speed, or rather maximum the speed limit.

How the results were obtained: when iperf is used without the `-b' option, it
                               completely tries to overrun the socket with data,
                               so for all packet sizes less than 1420 bytes,
                               the -b switch was set to the default value (1 Mbps);
                               for 1420b it was set to `-5m' which corresponds to a
                               constant bitrate of 5Mbps.


2. Audio streaming using paraslash
----------------------------------
CCID4 was set as default CCID using the {rx,tx}_ccid sysctls and a longer (50 min) MP3
file was streamed from server to client. It is a less boring setup than iperf, since when
there is a problem, it will become audible very quickly.

When doing the MP3-streaming, I had on DCCPv6
 * average packet size: 160 bytes
 * and the X_recv observed in the DCCP-Acks was
   frequently set to 6042 bytes/sec
 * which corresponds to ~ 48kbps, which is in agreement with the above table
 * and it also agrees perfectly with the encoding of the MP3 file -- its
   header says that it was encoded for 48 kbps joint-stereo and I think
   that means constant bitrate since VBR in MP3 is a bit more complex.

Gerrit   
