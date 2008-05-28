From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 28 May 2008 06:55:17 +0000
Subject: Re: Experimental_DCCP_source_tree: Snapshot patch for kernel 2.6.24
Message-Id: <20080528065517.GC4480@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <483AA49E.2000804@libero.it>
In-Reply-To: <483AA49E.2000804@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Giuseppe, -
| 
|  Than, I have compiled the kernel, and regarded /net/dccp/feat.c I only read a warning:
|    /net/dccp/feat.c: .........warning: dccp_feat_oname: defined but not used
| 
|  So, I think that is all OK, isn't it?
| 
Yes, it should work now. Typically each patch that is in the directory
has been tested to work here on 4..7 different computers, but it seems not
sufficiently with all combinations of options.

The warning message will disappear when enabling 'DCCP debug messages'
(via the 'DCCP kernel hacking' submenu), but you are right, it shouldn't
happen in any combination of configuration options.

I will fix this in the test tree and also in the 2.6.24 snapshot patch.

Thanks a lot for reporting this,
Gerrit
