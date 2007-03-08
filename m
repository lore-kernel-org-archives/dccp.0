From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Mar 2007 08:58:02 +0000
Subject: Re: kernel BUG at kernel/timer.c:407!
Message-Id: <200703080858.02864@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070305143240.GW22572@skl-net.de>
In-Reply-To: <20070305143240.GW22572@skl-net.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Andre Noll:
|  On 10:24, Andre Noll wrote:
|  > > Can you confirm that, when the `culprit' patch is reverted (as per
|  > > the first email), the bug disappears?
|  > 
|  > I double-checked this before sending the first mail, but I also will
|  > try the patch you sent today and report tomorrow.
|  
|  I now can confirm that also with 2.6.21-rc3 your patch makes the bug
|  go away, so feel free to add my Signed-Off.

Would have liked to do that since in effect you identified this issue.
For a sign-off it is probably too late, but in any case it is noted in the
commit message.

Glad to hear that the bug is remedied - that means two issues solved :)

Thanks again
Gerrit
