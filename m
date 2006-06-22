From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 22:23:23 +0000
Subject: HOWTO profile CCID2
Message-Id: <20060622222323.GA2291@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The Practice:
======wget darkircop.org/profile.tgz
cd profile
make

insmod ccid2.ko ccid2_profile=1

./profiler log

LD_PRELOAD=./libintr.so iperf -X DCCP -i1 -l 1400 -c 1.2.3.5 -t 60

cat log | grep "^pid.* 0 " | awk '{print $3 " " $4}' > log.cwnd
cat log | grep "^pid.* 1 " | awk '{print $3 " " $4}' > log.rtt
cat log | grep "^pid.* 2 " | awk '{print $3 " " $4}' > log.pipe
cat log | grep "^pid.* 3 " | awk '{print $3 " " $4}' > log.rate

The Theory:
=====* If the module is loaded with profiling information, changes in CCID2's state
  will be recorded.
* Use getsockopt on the socket to obtain all profiling info.
* To simplify the process, I coded profiler.c which will poll getsockopt() on a
  socket and log info on a file.
* profiler.c needs a DCCP socket to monitor.  You can pass one to it via UNIX
  sockets.
* libintr will intercept library calls which create DCCP sockets.  When a DCCP
  socket is created, it will be sent to the profiler so that it can monitor it.
  This allows you to monitor the sockets created by a program [such as iperf]
  without having to screw with its code.

Details:
====
* RTT is initialized to -1, hence the giant number on the first sample.
* Pipe is only recorded if it varies > 3 I think.  Otherwise, you would get huge
  amounts of data [pipe normally varies +-1].
* X amount is allocated in the kernel for storing profiling information.  It is
  a ring buffer.  If there is an overflow, profiler.c will tell you.  Try either
  increasing allocated size in kernel or polling frequency.
