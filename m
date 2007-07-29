From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 29 Jul 2007 12:20:38 +0000
Subject: Re: [PATCH 4/5]: Always support Ack Vectors
Message-Id: <200707291320.38791@strip-the-willow>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_WYIrGdUayF6LJgo"
List-Id: <dccp.vger.kernel.org>
References: <200707261356.49095@strip-the-willow>
In-Reply-To: <200707261356.49095@strip-the-willow>
To: dccp@vger.kernel.org

--Boundary-00=_WYIrGdUayF6LJgo
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline

|  >  DCCP mandates a `minimum implementation' = CCID2
|  >      ==> CCID2 mandates Ack Vectors
|  >      ==> Ack Vectors are not optional but mandatory
|  
|  Its useful for debugging, reducing the complexity by disabling this feature.
|  
|  It is possible to build a kernel without CCID2, and thus without Ack
|  vectors, so I'd prefer to leave it as is.
|  
|  The major Linux OS vendors would always enable CCID2 and its
|  requirement, ACK vectors, to be standards compliant, of course.
I am not very fussy about this, especially since it is a case of "if it ain't broke,
don't fix it". You wrote most of this, if you think that it is useful to keep, then
I suggest to drop this subject (which means that I will bin the two patches I had
constructed, one to make CCID2 default, the other this one). 
And I am more than happy to drop this, so as to focus on more important issues.

I have just two comments:

 1. It is possible to disable both CCIDs, in this case sockets can not be created (returns ENOMEM).
    Attached is - for `fun', but really not for consideration - a patch with a Null-CCID. Gives 
    incredible performance, but no congestion control.

 2. Ian suggested to auto-disable Ack Vectors when CCID3 is loaded. There is an ugly problem here,
    I faced the same issue when working on the per-CCID MPS-settings (the FIXME which talks to the
    CCID infrastructure):
        * the spec and the code allow to have different CCIDs for forward and return path;
        * this is foremost a theoretical thing - it is like having e.g. TCP Reno for the data and
          TCP Hybla for the Acks that come back;
        * but the practical implementation causes no end of headaches:
          - With regard to Ian's suggestion, Ack Vectors must be enabled if at least one CCID is CCID2.
          - If CCID2 talks to CCID3 then CCID2 will want to have its Ack Vectors from the CCID3 peer.
            However, there is no CCID3 code to support Ack Vectors at the moment (and in the spec this
            is only implicit).
          - If CCID3 talks to CCID2 then CCID3 will want its X_recv and loss rate from the CCID2 peer.
            But how? CCID2 doesn't know these things.

=> Hence can we ditch these headache cases? I don't think that having CCID2 and CCID3 enabled on
   different paths of the same connection has more than theoretical relevance. Someone wanting
   to try both CCID2 and CCID3 can do this better by opening two separate sockets/connections.
   I think keeping this possibility open is of course a theoretical challenge, but it serves no 
   real practical purpose. What do you think - would you be ok disabling it and thus have clearer
   and more predictable practical runtime conditions?
   It would make Ian's suggestion and the work on the per-CCID MPS calculations much clearer.

Gerrit

--Boundary-00=_WYIrGdUayF6LJgo
Content-Type: text/x-diff;
  charset="utf-8";
  name="RFC_CCID-Naught.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="RFC_CCID-Naught.diff"

[DCCP]: Use a NULL CCID module as fallback

Currently DCCP will not work when a user disables both of the available
CCID modules. To avoid this dependency-based failure, this patch suggests
- for discussion only - a NULL congestion control module which patches
traffic through without any shaping at all.

Note: If the user so wishes, it is possible to operate this module with
      Ack Vectors enabled. But it is indeed quite pointless.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h    |    3 ++-
 net/dccp/ccids/Makefile |    3 +++
 net/dccp/ccids/ccid0.c  |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 1 deletion(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -171,6 +171,7 @@ enum {
 
 /* DCCP CCIDS */
 enum {
+	DCCPC_CCID_NONE = 0,
 	DCCPC_CCID2 = 2,
 	DCCPC_CCID3 = 3,
 };
@@ -360,7 +361,7 @@ static inline unsigned int dccp_hdr_len(
 /* initial values for each feature */
 #define DCCPF_INITIAL_SEQUENCE_WINDOW		100
 #define DCCPF_INITIAL_ACK_RATIO			2
-#define DCCPF_INITIAL_CCID			DCCPC_CCID2
+#define DCCPF_INITIAL_CCID			DCCPC_CCID_NONE
 #define DCCPF_INITIAL_SEND_ACK_VECTOR		1
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
--- a/net/dccp/ccids/Makefile
+++ b/net/dccp/ccids/Makefile
@@ -1,3 +1,6 @@
+obj-$(CONFIG_IP_DCCP)       += dccp_ccid0.o
+dccp_ccid0-y := ccid0.o
+
 obj-$(CONFIG_IP_DCCP_CCID3) += dccp_ccid3.o
 
 dccp_ccid3-y := ccid3.o
--- /dev/null
+++ b/net/dccp/ccids/ccid0.c
@@ -0,0 +1,46 @@
+/*
+ *  CCID 0: A non-congestion-control CCID
+ *  Necessary for the DCCP module to function at all when the user has
+ *  not set any congestion-control modules. Works, but doesn't do CC.
+ *
+ *  Copyright (c) 2007 Gerrit Renker
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#include "../ccid.h"
+#include "../dccp.h"
+
+static struct ccid_operations ccid0 = {
+	.ccid_id	= DCCPC_CCID_NONE,
+	.ccid_name	= "ccid-naught",
+	.ccid_owner	= THIS_MODULE,
+};
+
+static __init int ccid0_module_init(void)
+{
+	return ccid_register(&ccid0);
+}
+module_init(ccid0_module_init);
+
+static __exit void ccid0_module_exit(void)
+{
+	ccid_unregister(&ccid0);
+}
+module_exit(ccid0_module_exit);
+
+MODULE_AUTHOR("Gerrit Renker");
+MODULE_DESCRIPTION("A NULL CCID (no congestion control at all)");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("net-dccp-ccid-0");

--Boundary-00=_WYIrGdUayF6LJgo--
