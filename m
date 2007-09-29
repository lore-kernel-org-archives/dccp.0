From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 29 Sep 2007 16:41:56 +0000
Subject: [PATCH 0/3][BUG-FIX][RFC]: Error Codes on sockets
Message-Id: <200709291741.56554@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo,

can you please look at these patches with priority and consider these or a variation
for mainline - it is in response to the comment made by Remi about handling non-blocking
connect by looking at socket error codes.

Patches #1/#2 are related, but not the main point. They fix the error reporting when e.g.
              the server has no DCCP loaded and ICMP "Protocol unavailable" is returned.
              This was so far not interpretated.

Patch #3 is the one for I would be glad for feedback. This fixes the problem Remi reported,
         by interpreting the Reset code of the Reset packet. In this way, it is now possible
         to separate clean termination (sk_err = 0) from genuine errors (sk_err != 0). Now,
         the choices were:
         1) Mimic tcp_reset() by mapping "No Connection"/"Connection refused" to ECONNREFUSED
            and map everything else to ECONNRESET. 
            The problem that I found with this is that it throws away the variety of Reset codes
            defined by DCCP.
	 2) Map "No Connection"/"Connection refused" to ECONNREFUSED and everything else using
            a mapping scheme (e.g. bit-shift reset code + adding a constant). But this may lead
            to strange error codes when the scheme overlaps with existing error codes.
         3) Map as far as possible into error numbers. This has been done in the present patch,
            using a table (which could be easily changed). The difficulty that I found here is
            that the range of errnos is limited, so it is a kind of best-guess. For instance,
            "Agression penalty" is mapped into EDQUOT, which looks a bit strange when directly
            putting this into strerror(). But the advantage is that the API can catch and reinterpret
            this.

It is all very elementary, but has been found to work. I hope that there are ideas and suggestions as
to how to extend this (for instance the Data 1 ... 3 fields are not yet interpreted), but in light of
Remi's VLC patch it would be good to have at least a subset of this available in mainline - experimental
things can then remain in the test tree.

Best regards
Gerrit
       
