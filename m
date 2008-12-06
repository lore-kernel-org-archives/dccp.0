From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 06 Dec 2008 16:40:50 +0000
Subject: net-next-2.6 [PATCH 0/7] dccp: Feature negotiation - Part III (integration)
Message-Id: <1228581657-6724-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Dave,

please find enclosed the penultimate set, the first out of two in the last
block, of the feature-negotiation patch set submission.
I have checked these to compile individually.=20

Gerrit


Commit summary:
---------------
This is a continuation of an ongoing submission to provide feature/capabili=
ty
negotiation for DCCP endpoints (RFC 4340 - 4342, 5348).

The whole set is structured into 3 main blocks - (1) basis, (2) core, (3)
integration and cleanup.

This set is the first out of two in block (3) and  removes the old, now unu=
sed,
parts of the older interface and begins the integration of the new interfac=
e=20
that formed part (2) of this submission.

The second and last part of block (3) deals with the initialization of=20
feature-negotiation state.


List of patches in this set:
----------------------------
Patch #1: Integration of dynamic negotiation, part I (socket setup).
Patch #2: Integration of dynamic negotiation, part II (server side).
Patch #3: Integration of dynamic negotiation, part III (client side).
Patch #4: Cleans up the older infrastructure.
Patch #5: Removes obsolete parts of the old CCID interface.
Patch #6: Removes manual intervention on NDP count (now automatic).
Patch #7: Removes Ack Vector sysctl (handled automatically now).

The set is also available for viewing online, beginning at
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;h=C47390a8b5faaec4a41337714b2d80c85fc6ba26


Patch stats:
------------
 Documentation/networking/dccp.txt |   11=20
 include/linux/dccp.h              |   10=20
 net/dccp/ccid.c                   |   14 -
 net/dccp/ccid.h                   |    5=20
 net/dccp/dccp.h                   |    4=20
 net/dccp/diag.c                   |    2=20
 net/dccp/feat.c                   |  519 ---------------------------------=
-----
 net/dccp/feat.h                   |   12=20
 net/dccp/input.c                  |   42 ++-
 net/dccp/minisocks.c              |   46 ---
 net/dccp/options.c                |   11=20
 net/dccp/proto.c                  |   49 ---
 net/dccp/sysctl.c                 |   14 -
 13 files changed, 70 insertions(+), 669 deletions(-)
