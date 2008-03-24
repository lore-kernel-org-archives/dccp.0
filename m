From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 24 Mar 2008 14:32:30 +0000
Subject: Re: dccp bugs
Message-Id: <20080324143230.GC32612@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Mar 24, 2008 at 02:04:15PM +0000, Gerrit Renker escreveu:
> | > Can you try the `ss' command from the iproute package when the problem
> | > occurs, using `ss -nadep' to display the DCCP states?
> | >
> | $ ss -nadep
> | State       Recv-Q Send-Q                        Local Address:Port                          
> | Peer Address:Port
> | FIN-WAIT-1  0      0                                 127.0.0.1:2008                             
> | 127.0.0.1:29792  ino:0 sk:d301d3c0
> | 
> I almost expected that it would be this state. I have also encountered
> this when aborting applications in a non-expected way.
> 
> The state FIN-WAIT-1 is mapped into ACTIVE_CLOSEREQ, i.e. the server seems
> to be the one running on port 2008; it has sent a CloseReq, asking the client
> to terminate the connection. The DCCP spec says that the CloseReq must be
> retransmitted (RFC 4340, 8.3.1).
> 
>    Endpoints in the CLOSEREQ and CLOSING states MUST retransmit DCCP-
>    CloseReq and DCCP-Close packets, respectively, until leaving those
>    states.  The retransmission timer should initially be set to go off
>    in two round-trip times and should back off to not less than once
>    every 64 seconds if no relevant response is received.
> 
> Hence the implementation is according to the spec - the server will
> retry until it gets the required DCCP-Close from the client, and only
> then leave the CLOSEREQ state.

IIRC Thomas said that the server process terminates, its just the client
that hangs for a long time, lemme re-read the other messages...

<quote Thomas>
 When I run ./server then ./client packets are sent but client program
 finishes executions only after all packets from queue are sent. Which
 is I guess quite ok. The problem happens when I kill the server program
 while client is running and sending packets.  The client detects that
 the connection is broken and starts returning error 32 from sendmsg
 call. But after it finishes sending packets it hangs on exit and even
 kill -9 doesn't work. It finishes after quite a long time (eg.  10
 minutes).
</quote>

Thomas, is it the client that hangs? Or is it the server?

- Arnaldo
