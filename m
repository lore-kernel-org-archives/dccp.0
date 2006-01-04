From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 04 Jan 2006 04:12:32 +0000
Subject: [PATCH 1/4][DCCP] ackvec: Fix spelling of "throw"
Message-Id: <39e6f6c70601032012v5c4b60bavdf8bdae4d8bb62ef@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_37817_21064699.1136347952766"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_37817_21064699.1136347952766
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

 Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.git

Best Regards,

- Arnaldo

------=_Part_37817_21064699.1136347952766
Content-Type: text/x-patch; name=1.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="1.patch"

tree 999897434bf2f6e7ad905f28949bed30ae76e279
parent 40efc6fa179f440a008333ea98f701bc35a1f97f
author Andrea Bittau <a.bittau@cs.ucl.ac.uk> 1136346317 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1136346317 -0200

[DCCP] ackvec: Fix spelling of "throw"

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ackvec.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index c9a62cc..a979f4e 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -291,7 +291,7 @@ void dccp_ackvec_print(const struct dccp
 }
 #endif
 
-static void dccp_ackvec_trow_away_ack_record(struct dccp_ackvec *av)
+static void dccp_ackvec_throw_away_ack_record(struct dccp_ackvec *av)
 {
 	/*
 	 * As we're keeping track of the ack vector size (dccpav_vec_len) and
@@ -326,7 +326,7 @@ void dccp_ackvec_check_rcv_ackno(struct 
 			      debug_prefix, 1,
 			      (unsigned long long)av->dccpav_ack_seqno,
 			      (unsigned long long)av->dccpav_ack_ackno);
-		dccp_ackvec_trow_away_ack_record(av);
+		dccp_ackvec_throw_away_ack_record(av);
 		av->dccpav_ack_seqno = DCCP_MAX_SEQNO + 1;
 	}
 }
@@ -389,7 +389,7 @@ static void dccp_ackvec_check_rcv_ackvec
 					      av->dccpav_ack_seqno,
 					      (unsigned long long)
 					      av->dccpav_ack_ackno);
-				dccp_ackvec_trow_away_ack_record(av);
+				dccp_ackvec_throw_away_ack_record(av);
 			}
 			/*
 			 * If dccpav_ack_seqno was not received, no problem



------=_Part_37817_21064699.1136347952766--
