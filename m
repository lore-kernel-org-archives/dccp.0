From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 05 Oct 2009 10:53:09 +0000
Subject: [PATCH 0/4][RFC]: coding convention for CCID-struct prefixes
Message-Id: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo, Dave,

this codifies new naming scheme discussed at netconf. Can you please have a
look and indicate whether you are ok with the set?

They are divided into 4 for readability, but can be combined into
one large patch if agreed.

It is all just regexp substitutions:

Patch #1: Introduces the naming scheme on CCID-2:
	    s#hc\(tx\|rx\)->ccid2hc\1_#hc\1->\1_#g;
            s#ccid2hc\(tx\|rx\)_#\1_#g;

Patch #2: Extends the changes of patch#1 to CCID-3.

Patch #3: Removes the second, repetitive redundancy in this scheme:
	    s#hc\(tx\|rx\)->\1_#hc->\1_#g;

Patch #4: Extends patch#3 from CCID-2 to CCID-3.

--
 ccids/ccid2.c |  595 ++++++++++++++++++++++++-------------------------
 ccids/ccid2.h |   46 +--
 ccids/ccid3.c |  692 +++++++++++++++++++++++++++-------------------------------
 ccids/ccid3.h |  120 +++++-----
 probe.c       |   22 -
 5 files changed, 723 insertions(+), 752 deletions(-)

