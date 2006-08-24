From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 24 Aug 2006 03:16:33 +0000
Subject: [PATCH 0/7] [DCCP]: Fixes and enhancements
Message-Id: <200608241516.34448.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Please find following a series of patches for DCCP.

These have been tested against torvalds/linux-2.6.git and davem/net-2.6.19.git

My opinion is that 1 and 2 can go straight into 2.6.18 as documentation
changes only - Dave - are you able to do as Arnaldo is very busy at present.

I would love 3, 4, 5 to go into 2.6.18 as these resolve long standing CCID3
issues that have been in the DCCP tree since inception and have caught a
number of people.

Number 6 is just shifting code around to tidy it up and introduces no change
in logic. You could argue for it to go in either 2.6.18 or 2.6.19!

Number 7 is implementing transmit buffering and is 2.6.19 material.
Andrea - this might be quite useful for you in CCID2 as well I believe.

These patches are all capable of being done independently except 3, 4, 5 which
are a group.

Also on http://wand.net.nz/~iam4/dccp/patches/ are the following further
patches which are not ready for merge but others might be interested in:
-DCCP-Probe ala TCP-Probe
-The starts of memory buffer limiting (this is not actually needed for number
7 as it is actually receive where problems occur which is an existing issue)
-My research code

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
