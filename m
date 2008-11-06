From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 06 Nov 2008 05:40:10 +0000
Subject: net-next-2.6 [PATCH 0/4] dccp: Feature negotiation - conclusion of Part I (basis)
Message-Id: <1225950014-6337-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Dave,

please find via the following 4 emails the remaining patches for
the first set part of the feature-negotiation patch set.

I have checked each individually to compile cleanly.

Best regards
Gerrit


Commit summary
--------------
The set concludes the first set of the feature negotiation patches to provi=
de
a self-contained feature negotiation API for the DCCP protocol (RFC 4340-2).

The whole set is structured into 3 main blocks - (1) basis, (2) core,
(3) integration and cleanup.

Within these blocks, this is the second set and its purpose is to conclude
the base implementation, preparing for the (15) core patches in the second =
set.


List of patches in this set:
----------------------------
Patch #1: Changes the existing policy to allow anytime changes as that lead
          to unpredictable results.
Patch #2: Adds registration routines. These form part of the user interface
          and are later used by the socket API to set individual preference=
s.
Patch #3: CCIDs are a negotiable feature. This patch adds support to query =
the
          supported CCIDs, so as to advertise only the locally supported on=
es.
Patch #4: The choice of CCID in turn creates new feature dependencies. The =
patch
          adds automatic tracking of such dependencies to avoid later failu=
re.

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;h=822761d3e69a1f7f8b994d1d7efd7771351e0195


Patch stats:
------------
 Documentation/networking/dccp.txt |    4=20
 include/linux/dccp.h              |    1=20
 net/dccp/ccid.c                   |   48 +++++
 net/dccp/ccid.h                   |    5=20
 net/dccp/ccids/ccid2.c            |    6=20
 net/dccp/dccp.h                   |    1=20
 net/dccp/feat.c                   |  306 +++++++++++++++++++++++++++++++++=
-----
 net/dccp/feat.h                   |   25 ++-
 net/dccp/options.c                |   18 --
 net/dccp/output.c                 |    4=20
 net/dccp/proto.c                  |    7=20
 net/dccp/timer.c                  |   12 -
 12 files changed, 368 insertions(+), 69 deletions(-)
