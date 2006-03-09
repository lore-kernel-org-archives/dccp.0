From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 09 Mar 2006 03:08:09 +0000
Subject: [PATCH 1/5] [DCCP] options: Fix handling of ackvecs in DATA packets
Message-Id: <11418736891639-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I.e. they should be just ignored, but we have to use 'break', not 'continue',
as we have to possibly reset the mandatory flag.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/options.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

2024e6ce3ab42e925411b4e51710bfdd09b38e72
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 8867b6f..0161a18 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -148,7 +148,7 @@ int dccp_parse_options(struct sock *sk, 
 		case DCCPO_ACK_VECTOR_0:
 		case DCCPO_ACK_VECTOR_1:
 			if (pkt_type = DCCP_PKT_DATA)
-				continue;
+				break;
 
 			if (dp->dccps_options.dccpo_send_ack_vector &&
 			    dccp_ackvec_parse(sk, skb, opt, value, len))
-- 
1.2.2.gd27d


