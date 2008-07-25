From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 14:28:34 +0000
Subject: v2 [net-2.6 PATCH 0-4/7] dccp: Revised ICMP bug fixes
Message-Id: <20080725142834.GA7422@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

this patch set addresses the two bugs you pointed out in the first revision.

And that was very good, because the same problem loomed in another corner: the
normal DCCP input receive path did the same unchecked de-referencing.
This is documented in patch #5, and increases the number of bugs fixed by
this changeset.

Patches 1..4 have not changed, they can be viewed online at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-2.6.git;a=summary

These patches are new or revised:
---------------------------------
Patch #5: Fixes minimum-required length check for DCCP packet input path.
Patch #6: Fixes minimum-required length check for ICMPv4 embedded DCCP datagrams
Patch #7: Same as patch #5, but for ICMPv6.

I have tested these on two different architectures.


As per the first revision, this changeset can be pulled both from

	git://eden-feed.erg.abdn.ac.uk/net-2.6		(subtree `master')

and from 	

   	git://eden-feed.erg.abdn.ac.uk/net-next-2.6	(subtree `master')


Thanks a lot for pointing out the bugs,
Gerrit       
