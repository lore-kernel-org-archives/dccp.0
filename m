From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 30 Aug 2008 13:52:01 +0000
Subject: Re: [PATCH 08/37] dccp: Query supported CCIDs
Message-Id: <20080830135201.GC17190@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > This provides a data structure to record which CCIDs are locally supported
| > and three accessor functions:
<snip> 
| But this limits us to the CCIDs at kernel build time, what if I want to
| test CCID4? I guess we could have something like a bitmap and check if
| the bit for that CCID is set, and it would be set at ccid_register time.
| 
| Perhaps using include/linux/bitmap.h :-)
| 
I looked at it and it actually seems an attractive idea. I have the
following suggestion: the key point of this patch set to improve the
present (mainline) interface for feature negotiation.

People have complained earlier about crashes when trying to negotiate
different CCIDs with the present mechanism. I think this happened with D-ITG.

For the present patch set I would like to keep it as it is, since the
existing CCIDs are buggy/incomplete enough to delay work on entirely new
CCIDs.

But the test tree has still empty disk space for lots of patches, so
this is an invitation to contribute.
