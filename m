From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Mar 2008 10:48:32 +0000
Subject: Re: dccp bugs
Message-Id: <20080325104832.GC10458@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Tomasz Grobelny:
| Dnia Monday 24 of March 2008, Arnaldo Carvalho de Melo napisa?:
| > IIRC Thomas said that the server process terminates, its just the client
| > that hangs for a long time, lemme re-read the other messages...
| Yes, you are right.
| 
| > Thomas, is it the client that hangs? Or is it the server?
| >
| It is the client (the program that does connect(...)) that hangs. The server 
| (the one which does listen(...)) is already dead. Well, the server process 
| finished execution but the socket is somehow busy: when I try to run the 
| server once again (on the same port) and try to connect to it with another 
| instance of the client program I always get this 32 return code from sendmsg 
| call.
Ok, it is clearer now: the "somehow busy" is related to the `ss' output,
where the server tries to resend its CloseReq (as per other email).

Since it is the client that hangs and which sends packets, there is a
very good chance that the recent patches in the test tree will fix that
problem, in particular as it is related to 
 * aborting a client with a full write queue,
 * closing a client with a full write queue while the client can't send.

If possible, can you please try the test tree patches and see if the
problem persists. I am doing a lot of testing and have not observed any
similar errors in the test tree -- the closest being the server-hand on
retransmitting CloseReq, which may account for the earlier confusion.

You need not pull git, patches are available for recent standard kernels on:
http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/
