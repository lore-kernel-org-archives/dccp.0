From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 15 Apr 2007 16:41:06 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <200704151741.07021@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Basically if RTT is extremely low, don't do any of this limiting.
I think we should find a way of implementing this hint in CCID3,
if Eddie disagrees, maybe as experimental or Kconfig option.

This concept is different from the `preventing oscillations' idea
(which we should also do, I know); yet it will be something encountered
on almost any network that a CCID3 client runs on.


Coming back to the patch referred to in the subject-line - I would
like to keep that in for the moment; for the very reason that the
rate-pacing is broken, so that this patch avoids putting more kerosene
into the fire (remember, this patch is not about RTTs).

If you like I can change the comment above the single two lines of code
that this patch introduces; but I would still like to keep it.

And it is something which can easily be changed once the other issues
have been resolved. Plus, it is a safe option.
