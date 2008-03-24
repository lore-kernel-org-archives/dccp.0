From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 24 Mar 2008 16:02:18 +0000
Subject: Re: dccp bugs
Message-Id: <20080324160218.GA19959@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | > Can you try the `ss' command from the iproute package when the problem
| > | > occurs, using `ss -nadep' to display the DCCP states?
| > | >
| > | $ ss -nadep
| > | State       Recv-Q Send-Q                        Local Address:Port                          
| > | Peer Address:Port
| > | FIN-WAIT-1  0      0                                 127.0.0.1:2008                             
| > | 127.0.0.1:29792  ino:0 sk:d301d3c0
| > | 
<snip>
| 
| IIRC Thomas said that the server process terminates, its just the client
| that hangs for a long time, lemme re-read the other messages...
| 
| <quote Thomas>
|  When I run ./server then ./client packets are sent but client program
|  finishes executions only after all packets from queue are sent. Which
|  is I guess quite ok. The problem happens when I kill the server program
|  while client is running and sending packets.  The client detects that
|  the connection is broken and starts returning error 32 from sendmsg
|  call. But after it finishes sending packets it hangs on exit and even
|  kill -9 doesn't work. It finishes after quite a long time (eg.  10
|  minutes).
| </quote>
| 
This is a good point, but now it gets confusing. The FIN-WAIT-1/active
CLOSEREQ state can only happen on the server, so maybe the above output
is not the right one.
