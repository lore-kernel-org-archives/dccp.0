From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 20 Jul 2006 18:02:29 +0000
Subject: [PATCH 2/3]: ACKVEC: Optimization - Do not traverse records if none will be found
Message-Id: <20060720180229.GB3313@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Do not traverse the list of ack vector records [proportional to window size]
when we know we will not find what we are looking for.  This is especially
useful because ack vectors are checked twice:
1) Upon parsing of options.
2) Upon notification of a new ack.

All of the work will occur during check #1.  Therefore, when check #2 is
performed, no new work will be done.  This is now "detected" and there is no
performance hit when doing #2.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 35308cf..73cb055 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -416,7 +416,8 @@ #endif
 				      (unsigned long long)avr->dccpavr_ack_ackno);
 			dccp_ackvec_throw_record(av, avr);
 			break;
-		}
+		} else if (avr->dccpavr_ack_seqno > ackno)
+			break; /* old news */
 	}
 }
 
