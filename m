From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 02:25:15 +0000
Subject: [PATCH 0/7] [DCCP]: Further fixes and enhancements
Message-Id: <200609221425.16349.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here is my latest set of patches for DCCP.

If possible I would like these to go into 2.6.19. I have tested against
2.6.18rc5 and latest net-2.6.19 git tree of Dave M as well.

Dave - Patches 1 and 2 are trivial and just introducing constants and using
them. Patch 4 is shifting some code into a header. If patch 3 could be
merged also that would be great - it is just about the same as Stephen
Hemminger's TCP Probe code but instead for DCCP. Patch 3 depends on patch 1.

I think it would be good for Arnaldo or another person to sign off on 5, 6
and 7 after a bit more of a look. These fix up packet size setting for 
CCID3 and also change them to work on half connections as you may have
different packet sizes for each. I've tested myself thoroughly but others
might have an opinion on the style of these. These three patches need to be 
applied in order.

Ian
