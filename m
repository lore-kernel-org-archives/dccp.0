From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 10 Jan 2008 11:31:03 +0000
Subject: Re: FW: ccid2/ccid3 oopses
Message-Id: <20080110113103.GA5606@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <93680347@web.de>
In-Reply-To: <93680347@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > So maybe the cause triggering this oops is somewhere else.
| 
| yes, probably.  sorry - i didn`t tell or maybe i didn`t know when writing
| my first mail to module authors and forget to add that before forwarding here.
| 
| for me , the problem does not happen with suse kernel of the day
| (2.6.24-rc6-git7-20080102160500-default, .config attached) but it happens
| with vanilla 2.6.24-rc6 (mostly allmodconfig, also attached)
| 
There are 256 differences between the two .config files. I think there are other
people on the list who will be able to give more information regarding the .config
files. The differences that struck me in the one which doesn't work is

 -- CONFIG_DEBUG_KERNEL     and
 -- CONFIG_DEBUG_BUGVERBOSE were not set. Both are very useful for bug-hunting,
                            the latter is much better for decoding oopses.

Can't say anything about the Suse kernel. We use the plain kernel from www.kernel.org, 
specifically the netdev-tree:
	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
If you can't get further here, try with a kernel.org kernel or check Suse forums.	

 1. the tests yesterday were done on the DCCP test tree based on the above netdev-2.6
    2.6.24-rc7 tree from git://eden-feed.erg.abdn.ac.uk/dccp_exp   (dccp subtree)
    Tested your for-loop 60 seconds each for CCID3/4 -- no oops.

 2. also repeated the tests on an unmodified 2.6.24-rc7 tree from netdev-2.6 (today)
    120 seconds for-loop each -- no oops.	

As said, if the above does not help, try a www.kernel.org kernel (or one of the
above trees) first.
| 
| >| > >> the easiest way to reproduce is:
| > | > >> 
| > | > >> while true;do modprobe dccp_ccid2/3;modprobe -r dccp_ccid2/3;done
| > | > >> after short time, the kernel oopses (messages below)
| > | > >> 
