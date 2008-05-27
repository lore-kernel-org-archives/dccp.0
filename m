From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 14:16:37 +0000
Subject: Re: [PATCH 4/7] [CCID-3]: Fix "t_ipi explosion" bug
Message-Id: <20080527141637.GB28240@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1211877167-10995-5-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1211877167-10995-5-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| 
| Because you're mixing coding style cleanups, both of which I've
| just NACK'd, with real bug fixes, you're making a lot of work for
| me.
|
I am sorry, but I was under the impression that you were busy already
and thus that the fixes would need to wait until net-next-2.6.

This was in part my fault and would have been avoidable, since I had
actually created both trees in parallel with the same set of patches:

	git://eden-feed.erg.abdn.ac.uk/net-2.6.git
	git://eden-feed.erg.abdn.ac.uk/net-next-2.6.git

I'd suggest to stop for now, I will resubmit the whole lot which
inevitably will need to be recoded.

Gerrit
