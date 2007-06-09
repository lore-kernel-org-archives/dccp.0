From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 09 Jun 2007 18:29:26 +0000
Subject: [PATCH 0/3]: Upgrade to ktime_t
Message-Id: <200706091929.26290@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch updates some of the code to use the newer ktime_t interface.
It is the begin of a longer patch set (see note at end).

Patch #1: Provides an analogue of timeval_delta() with ktime_t and in usecs.
Patch #2: Updates the CCID3 sending time interface to use ktime_t.
Patch #3: Updates computation of X in CCID3 to use ktime_t.

P L E A S E   N O T E:
----------------------
This is the begin of a longer patch set, which is inter-dependent. Inter-dependencies
are unavoidable, since part of the patch makes architectural changes. Patches in themselves
are presumed correct (at least in my eyes :), I will point out the last patch of the series 
explicitly (i.e. when it is ok to feed them to gcc).

It is planned to put these and other patches into an experimental DCCP tree.

I am putting them out now so that people can comment and so that discussion points can
be resolved early, not after the 49th patch.

Thanks.
