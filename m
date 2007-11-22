From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 22 Nov 2007 15:38:43 +0000
Subject: [RFC]: Withdrawal of passive-close patches
Message-Id: <20071122153843.GA13762@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

After fixing the issue with the leaked-skbs I spent nearly a day trying
to provoke the problem that lead to the following two patches:

   [DCCP]: Dedicated auxiliary states to support passive-close
   [DCCP]: Basic support for passive-close
   [DCCP]: More informative state names

It is almost 8 months ago that I worked on these (my notes say 28th March)
and I don't have the source code of the test program I used. I was sure
that there was a problem since I was able to see the data on the wire
but it didn't reach the application.

Really, I can't remember what the condition was. It may have been some
kind of race condition, or something which can be dealt with at the
application programming level rather than at the kernel level.

The case may be that ... 
 1. I misjudged the cause of the problem;
 2. the problem may have disappeared during the 8 months of kernel changes;
 3. the problem may re-appear later on.

The current solution is to enqueue the DCCP-Close and DCCP-Reset so that
these come last in the receive buffer. I am actually hoping that I am 
wrong (case (1)), since the current solution is much simpler than the one
I was suggesting and "simpler is better".

So I suggest to remove / not consider the following three patches:
   [DCCP]: Dedicated auxiliary states to support passive-close
   [DCCP]: Basic support for passive-close
   [DCCP]: More informative state names

If you or anyone on the list can create a condition which will lead to
"application received data but didn't have a chance to read it", I'd like
to hear about it.

For now, I will update the test tree (remove the above trio) and remove
the online notes: they may at best be outdated and at worst plain wrong.
