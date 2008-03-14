From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 14 Mar 2008 13:33:24 +0000
Subject: Re: dccp bugs (Was: Re: panic on 2.6.24rc5)
Message-Id: <20080314133324.GA22237@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

With thanks to Cheng Wei, the bug reported by Tomasz on loopback
has now been resolved. The reason is that
 * the RFC4342 window counter algorithm (which uses RTT/4) does not work
   for RTTs < 4 microseconds with the current resolution of 1 microsecond
   in the Linux implementation (divide-by-zero);
 * as a result, the window counter does not change when RTT < 4 usec;
 * which causes the nofeedback timer to halve the sending rate until
   reaching s/t_mbi (1 packet in 64 seconds).

There were some errors in the analysis document on 

http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3/ccid3_over_loopback/

(specifically section 3). These have been corrected, and a new version
has been uploaded.

With regard to the RTT-clamping patch: I have heard no report back from
Tomasz, but with the revised analysis I am sure that the bug will
disappear when clamping the RTT to values > 4 microseconds.

Although therefore clamping at 10 microseconds would be sufficient, I
still think that a greater value will be better. After all, the packet
scheduling is on the order of milliseconds.

Will post patch etc. early next week.

Gerrit
