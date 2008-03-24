From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 24 Mar 2008 14:04:15 +0000
Subject: Re: dccp bugs
Message-Id: <20080324140414.GA14493@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > Can you try the `ss' command from the iproute package when the problem
| > occurs, using `ss -nadep' to display the DCCP states?
| >
| $ ss -nadep
| State       Recv-Q Send-Q                        Local Address:Port                          
| Peer Address:Port
| FIN-WAIT-1  0      0                                 127.0.0.1:2008                             
| 127.0.0.1:29792  ino:0 sk:d301d3c0
| 
I almost expected that it would be this state. I have also encountered
this when aborting applications in a non-expected way.

The state FIN-WAIT-1 is mapped into ACTIVE_CLOSEREQ, i.e. the server seems
to be the one running on port 2008; it has sent a CloseReq, asking the client
to terminate the connection. The DCCP spec says that the CloseReq must be
retransmitted (RFC 4340, 8.3.1).

   Endpoints in the CLOSEREQ and CLOSING states MUST retransmit DCCP-
   CloseReq and DCCP-Close packets, respectively, until leaving those
   states.  The retransmission timer should initially be set to go off
   in two round-trip times and should back off to not less than once
   every 64 seconds if no relevant response is received.

Hence the implementation is according to the spec - the server will
retry until it gets the required DCCP-Close from the client, and only
then leave the CLOSEREQ state.

| > DCCP is connection-oriented, so killing a server/client is different
| > from UDP. When you try to kill a DCCP node, it will first try to finish
| > its connection. The `hang' effect is most likely due to an uncompleted
| > system call such as close(), and it is in a non-interruptible state.
| >
| 10 minutes for an uninterruptible call seems to be quite a long time. If I 
| were a system administrator it would probably drive me mad.
| 
I think that there are cases in TCP where TCP is similarly pernicious.
Not least because DCCP uses the same sysctls (request_retries,
retries1, retries2).

| > I am aware that there is at least one patch which may remedy the problem
| > you encountered, which is the patch to clean up the write queue on
| > (forced) disconnect, also the wait-for-ccid cleanup routine which
| > flushes the write queue at the end of the connection.
| >
| Is it in experimental tree?
| 
Yes theses patches are all in the experimental tree. What they do is to
purge the write queue on abnormal termination and they ensure that
flushing the write queue at the end of a connection takes no longer than
the SO_LINGER time. 

But as you already said that the problem happens with both CCIDs, it may
(or may not, am not entirely sure) be that this does not help with the
long timeouts. It is definitively worth a try:
http://www.linux-foundation.org/en/Net:DCCP_Testing#Experimental_DCCP_source_tree	

| > There are also sysctls to reduce the number of attempts to repeat a
| > (futile) close at the end, in Documentation/networking/dccp.txt
| You mean the *retries* entries? Setting all three to 1 doesn't make it any 
| better.
How to quantify `better'? Changing valueswill not change the problem as such, but
it will reduce the timeout until the server gives up. And from earlier
tests (about 1+1/2 years ago when the sysctls were activated) I recall that
this worked correctly.

There are alternatives, the first relates to your comment below.
| And one more thing: if I try to interrupt the client program before it reaches 
| its end all is fine - the program finishes execution immediately.
| -- 
In this case the long timeout is avoided: the client either sends a Reset (when
it still has unread data or SO_LINGER with linger=0 is used) or a Close
if it terminates cleanly. In this case the server directly closes and
does not enter into CLOSEREQ where it is required to retransmit the
CloseReq.

So to get around the annoyance, killing the client first avoids these
long waiting times.

(The other alternative is to enable the DCCP_SOCKOPT_SERVER_TIMEWAIT
 option (documented also in Documentation/networking/dccp.txt), where the
 server sends just a single close. But if here also the client dies
 before the server, the server would have to retransmit the Close also.)
