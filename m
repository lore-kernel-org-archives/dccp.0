From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 31 Mar 2008 06:41:43 +0000
Subject: Re: dccp bugs
Message-Id: <20080331064143.GB6089@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803232131.58407.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > If possible, can you please try the test tree patches and see if the
| > problem persists. I am doing a lot of testing and have not observed any
| > similar errors in the test tree -- the closest being the server-hand on
| > retransmitting CloseReq, which may account for the earlier confusion.
| >
| Yes, it works ok now. I was already using the test tree before but the wrong 
| branch.
Thanks very much for testing. I have a suspicion that the fix is in one
of the following patches:

 [CCID]: Refine the wait-for-ccid mechanism        
 [DCCP]: Empty the write queue when disconnecting 

Both flush the write queue on exit. The first one limits the amount of
time that close() will allow to drain the write queue, the second patch
flushes the write queue when the connection is aborted.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

