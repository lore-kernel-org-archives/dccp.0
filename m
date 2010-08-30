From: David Miller <davem@davemloft.net>
Date: Mon, 30 Aug 2010 20:46:38 +0000
Subject: Re: net-2.6 [PATCH 0/5] dccp: ccid-2 clean-up; code sharing
Message-Id: <20100830.134638.27802080.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Aug 2010 07:23:09 +0200

> All patches have been tested to compile independently and are at the top of
> git://eden-feed.erg.abdn.ac.uk/dccp_exp (subtree 'dccp').

WHat was this 'dccp' branch based upon?  I tried to pull it into
net-next-2.6 and got lots of unrelated changes and several
conflicts.

If you want me to pull your GIT tree it has to be clean,
against the proper tree, and I should only ever get your
specific changes and absolutely nothing unrealted.

I've applied the 5 patches by hand instead, they all
look fine, thanks!
