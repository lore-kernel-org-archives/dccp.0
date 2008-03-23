From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 23 Mar 2008 20:31:57 +0000
Subject: Re: dccp bugs
Message-Id: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

One more thing I noticed when using dccp...
I have a server which accepts connection, receives data and finishes execution 
and a client that sends 1000 data packets and finishes execution (see 
http://dccp.one.pl/svn/userspace/test/). When I run ./server then ./client 
packets are sent but client program finishes executions only after all 
packets from queue are sent. Which is I guess quite ok. The problem happens 
when I kill the server program while client is running and sending packets. 
The client detects that the connection is broken and starts returning error 
32 from sendmsg call. But after it finishes sending packets it hangs on exit 
and even kill -9 doesn't work. It finishes after quite a long time (eg. 10 
minutes). Am I doing something wrong or is it a bug in dccp? Tested on 
loopback with rate limiting (sudo tc qdisc add dev lo root handle 1:0 tbf 
rate 3kbit burst 3kbit latency 500ms). With rate limiting turned off I don't 
see any problems. Testing between two virtual machines with rate limiting on 
shows the same problem.
-- 
Regards,
Tomasz Grobelny
