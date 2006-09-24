From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 24 Sep 2006 21:17:08 +0000
Subject: [PATCH 0/4][DCCP]: Merge request
Message-Id: <20060924211708.GA6263@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

   Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.git

Best Regards,

- Arnaldo

 b/Documentation/networking/dccp.txt |    8 -
 b/include/linux/dccp.h              |    6 -
 b/net/dccp/Kconfig                  |   16 ++
 b/net/dccp/Makefile                 |    2
 b/net/dccp/ccids/ccid2.c            |    2
 b/net/dccp/ccids/ccid3.c            |    3
 b/net/dccp/ipv4.c                   |    3
 b/net/dccp/probe.c                  |  199 +++++++++++++++++++++++++++++++++++
 b/net/dccp/proto.c                  |   12 --
 include/linux/dccp.h                |    9 +
 10 files changed, 232 insertions(+), 28 deletions(-)

commit e41542f5167d6b506607f8dd111fa0a3e468ccb8
Author: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date:   Fri Sep 22 14:28:01 2006 +1200

    [DCCP]: Introduce dccp_probe

    This adds DCCP probing shamelessly ripped off from TCP probes by
Stephen
    Hemminger.

    I've put in here support for further CCID3 variables as well.
    Andrea/Arnaldo might look to extend for CCID2.

    Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
    Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

commit 3dd9a7c3a155ee96160876cba92439fdc96d7e0b
Author: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date:   Fri Sep 22 14:26:44 2006 +1200

    [DCCP]: Use constants for CCIDs

    With constants for CCID numbers this now uses them in some places.

    Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
    Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

commit b83eff641ed39bd631535b9a8971e161b056f541
Author: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date:   Fri Sep 22 14:25:36 2006 +1200

    [DCCP]: Introduce constants for CCID numbers

    Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
    Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

commit 00e4d116a7ef94eb910be037912b0b2fc09f608b
Author: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date:   Fri Sep 22 09:33:58 2006 +0100

    [DCCP]: Allow default/fallback service code.

    This has been discussed on dccp@vger and removes the necessity for
applications to supply service codes in each and every case.

    If an application does not want to provide a service code, that's
fine, it will be given 0. Otherwise, service codes can be set via socket
options as before.

    This patch has been tested using various client/server
configurations (including listening on multiple service codes).

    Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
    Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
