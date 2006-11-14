From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 14 Nov 2006 16:00:24 +0000
Subject: [PATCH 5/5][DCCP] ACKVEC: Optimization - Do not traverse records if none will be found
Message-Id: <20061114160023.GG6903@mandriva.com>
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
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ackvec.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 0c54b89..bd20a2c 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -383,7 +383,8 @@ void dccp_ackvec_check_rcv_ackno(struct 
 				      (unsigned long long)avr->dccpavr_ack_ackno);
 			dccp_ackvec_throw_record(av, avr);
 			break;
-		}
+		} else if (avr->dccpavr_ack_seqno > ackno)
+			break; /* old news */
 	}
 }
 
