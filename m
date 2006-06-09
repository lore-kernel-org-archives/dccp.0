From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Fri, 09 Jun 2006 18:26:49 +0000
Subject: [PATCH 1/1] DCCP Ackvec: fix soft lockup in ackvec handling code
Message-Id: <20060609182649.GA20777@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A soft lockup existed in the handling of ack vector records.  Specifically, when
a tail of the list of ack vector records was removed, it was possible to end up
iterating infinitely on an element of the tail.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 2349078..a856d72 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -453,6 +453,7 @@ #endif
 					      (unsigned long long)
 					      avr->dccpavr_ack_ackno);
 				dccp_ackvec_throw_record(av, avr);
+				break;
 			}
 			/*
 			 * If it wasn't received, continue scanning... we might
