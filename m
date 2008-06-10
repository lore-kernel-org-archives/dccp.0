From: David Miller <davem@davemloft.net>
Date: Tue, 10 Jun 2008 19:31:15 +0000
Subject: Re: [PATCH 1/7] dccp ccid-3: Bug-Fix - Zero RTT is possible
Message-Id: <20080610.123115.107060915.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1213102423-27486-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1213102423-27486-2-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 13:53:37 +0100

> Commit 825de27d9e40b3117b29a79d412b7a4b78c5d815 fixed the CCID-3 window counter
> computation for RTTs < 4 microseconds (as happens on loopback).

When referencing GIT SHA1 IDs in commit logs, always
provide the commit changelog header line text like
this:

	In commit $(SHA1_ID) ("[DCCP]: blah blah blah") we
	did whatever...

because if this patch is ported into another GIT tree,
the SHA1_ID of the referenced commit might be different
and the commit header line text helps people find the
correct change you are referring to even if this happens.

I say this to someone at least one time every day that I
integrate patches.  Please be mindful of this so I don't
have to ask you to do it again, thanks.
