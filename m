From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 26 May 2008 12:11:50 +0000
Subject: Re: Experimental_DCCP_source_tree: Snapshot patch for kernel 2.6.24
Message-Id: <20080526121150.GA12718@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <483AA49E.2000804@libero.it>
In-Reply-To: <483AA49E.2000804@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Giuseppe,

you are the second one to report this and I am beginning to think that
the snapshot patches may not be such a good idea. The problem is that
they are taken on the day that the `EXTRAVERSION' variable changes in
the top-level Makefile.

I have downloaded a 2.6.24, and found that 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/test-tree_2.6.24-rc8.diff.gz

applied cleanly, i.e. probably this is the version later published as
2.6.24 on kernel.org. Could you give this a try please?

But even then, the older patches are lacking some of the more recent
fixes. I will try to backport the latest snapshot patch to 2.6.24 if
I can find some time.

Gerrit
