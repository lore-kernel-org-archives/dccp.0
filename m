Received: from mailgw.kylinos.cn (mailgw.kylinos.cn [124.126.103.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A544C194136;
	Fri, 14 Jun 2024 10:31:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=124.126.103.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718361125; cv=none; b=eHvKcyzAsntYoojjgcZ4GWasqdiny9uwLFgrchGOm7z7LQOqBStfbKGgeAIx16igeOPil2eabBpDVolSPMBy65xuRFo4pQRc96jkH80VBXi3RlIVyNR3cYdeDrVfxaRoMO2T+m421WTAQioEVvAg0mL/Xjswcl5BBAgn6yIFDBU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718361125; c=relaxed/simple;
	bh=Pz7szoYVtQusFsqdF+uL5zaAzbsRI3qtXwDaAItdJXg=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=BmM0oQIqUL1VQPi3bEYtqezyGiHwrhzOGgNEW1dq+9rYNBQ/2J+/squUYBZgd1284EFErv0tx2/S3tfQIsMRvLXWwgIAbtz3mvnO2tllILobApKjJCrWxBlTV1jDyNhFWQ/nw9D+0dBhna+ot2/dvfSCtRTx2dIfWiEhDQ1Hyo0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn; spf=pass smtp.mailfrom=kylinos.cn; arc=none smtp.client-ip=124.126.103.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kylinos.cn
X-UUID: 913e5c122a3811ef9305a59a3cc225df-20240614
X-CID-P-RULE: Release_Ham
X-CID-O-INFO: VERSION:1.1.38,REQID:15153458-e1d1-41ff-8954-c66e7c695fc5,IP:10,
	URL:0,TC:0,Content:-25,EDM:-25,RT:0,SF:-5,FILE:0,BULK:0,RULE:Release_Ham,A
	CTION:release,TS:-45
X-CID-INFO: VERSION:1.1.38,REQID:15153458-e1d1-41ff-8954-c66e7c695fc5,IP:10,UR
	L:0,TC:0,Content:-25,EDM:-25,RT:0,SF:-5,FILE:0,BULK:0,RULE:EDM_GE969F26,AC
	TION:release,TS:-45
X-CID-META: VersionHash:82c5f88,CLOUDID:7f6ec4fb725e4e89490b4f9ca7a8b8ef,BulkI
	D:2406141826344BZEZ1OE,BulkQuantity:0,Recheck:0,SF:19|44|66|24|72|102,TC:n
	il,Content:0,EDM:1|19,IP:-2,URL:0,File:nil,RT:nil,Bulk:nil,QS:nil,BEC:nil,
	COL:0,OSI:0,OSA:0,AV:0,LES:1,SPR:NO,DKR:0,DKP:0,BRR:0,BRE:0
X-CID-BVR: 0
X-CID-BAS: 0,_,0,_
X-CID-FACTOR: TF_CID_SPAM_FSD,TF_CID_SPAM_FSI,TF_CID_SPAM_SNR
X-UUID: 913e5c122a3811ef9305a59a3cc225df-20240614
Received: from node2.com.cn [(39.156.73.10)] by mailgw.kylinos.cn
	(envelope-from <luoxuanqiang@kylinos.cn>)
	(Generic MTA)
	with ESMTP id 1670326747; Fri, 14 Jun 2024 18:26:31 +0800
Received: from node2.com.cn (localhost [127.0.0.1])
	by node2.com.cn (NSMail) with SMTP id 2ED58B80758A;
	Fri, 14 Jun 2024 18:26:31 +0800 (CST)
X-ns-mid: postfix-666C1AD7-467859
Received: from localhost.localdomain (unknown [10.42.12.252])
	by node2.com.cn (NSMail) with ESMTPA id 8A692B80758A;
	Fri, 14 Jun 2024 10:26:28 +0000 (UTC)
From: luoxuanqiang <luoxuanqiang@kylinos.cn>
To: edumazet@google.com
Cc: davem@davemloft.net,
	dsahern@kernel.org,
	fw@strlen.de,
	kuba@kernel.org,
	linux-kernel@vger.kernel.org,
	luoxuanqiang@kylinos.cn,
	netdev@vger.kernel.org,
	pabeni@redhat.com,
	kuniyu@amazon.com,
	dccp@vger.kernel.org
Subject: [PATCH net v2] Fix race for duplicate reqsk on identical SYN
Date: Fri, 14 Jun 2024 18:26:28 +0800
Message-Id: <20240614102628.446642-1-luoxuanqiang@kylinos.cn>
X-Mailer: git-send-email 2.25.1
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

When bonding is configured in BOND_MODE_BROADCAST mode, if two identical
SYN packets are received at the same time and processed on different CPUs=
,
it can potentially create the same sk (sock) but two different reqsk
(request_sock) in tcp_conn_request().

These two different reqsk will respond with two SYNACK packets, and since
the generation of the seq (ISN) incorporates a timestamp, the final two
SYNACK packets will have different seq values.

The consequence is that when the Client receives and replies with an ACK
to the earlier SYNACK packet, we will reset(RST) it.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

This behavior is consistently reproducible in my local setup,
which comprises:

                  | NETA1 ------ NETB1 |
PC_A --- bond --- |                    | --- bond --- PC_B
                  | NETA2 ------ NETB2 |

- PC_A is the Server and has two network cards, NETA1 and NETA2. I have
  bonded these two cards using BOND_MODE_BROADCAST mode and configured
  them to be handled by different CPU.

- PC_B is the Client, also equipped with two network cards, NETB1 and
  NETB2, which are also bonded and configured in BOND_MODE_BROADCAST mode=
.

If the client attempts a TCP connection to the server, it might encounter
a failure. Capturing packets from the server side reveals:

10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
localhost > 10.10.10.10.45182: Flags [S.], seq 2967855116,
localhost > 10.10.10.10.45182: Flags [S.], seq 2967855123, <=3D=3D
10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
localhost > 10.10.10.10.45182: Flags [R], seq 2967855117, <=3D=3D
localhost > 10.10.10.10.45182: Flags [R], seq 2967855117,

Two SYNACKs with different seq numbers are sent by localhost,
resulting in an anomaly.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

The attempted solution is as follows:
In the tcp_conn_request(), while inserting reqsk into the ehash table,
it also checks if an entry already exists. If found, it avoids
reinsertion and releases it.

Simultaneously, In the reqsk_queue_hash_req(), the start of the
req->rsk_timer is adjusted to be after successful insertion.

Signed-off-by: luoxuanqiang <luoxuanqiang@kylinos.cn>
---
 include/net/inet_connection_sock.h |  2 +-
 net/dccp/ipv4.c                    |  2 +-
 net/dccp/ipv6.c                    |  2 +-
 net/ipv4/inet_connection_sock.c    | 15 +++++++++++----
 net/ipv4/tcp_input.c               | 11 ++++++++++-
 5 files changed, 24 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connec=
tion_sock.h
index 7d6b1254c92d..8773d161d184 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -264,7 +264,7 @@ struct sock *inet_csk_reqsk_queue_add(struct sock *sk=
,
 				      struct request_sock *req,
 				      struct sock *child);
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock =
*req,
-				   unsigned long timeout);
+				   unsigned long timeout, bool *found_dup_sk);
 struct sock *inet_csk_complete_hashdance(struct sock *sk, struct sock *c=
hild,
 					 struct request_sock *req,
 					 bool own_req);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ff41bd6f99c3..13aafdeb9205 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -657,7 +657,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_b=
uff *skb)
 	if (dccp_v4_send_response(sk, req))
 		goto drop_and_free;
=20
-	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
+	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
 	reqsk_put(req);
 	return 0;
=20
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 85f4b8fdbe5e..493cdb12ce2b 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -400,7 +400,7 @@ static int dccp_v6_conn_request(struct sock *sk, stru=
ct sk_buff *skb)
 	if (dccp_v6_send_response(sk, req))
 		goto drop_and_free;
=20
-	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
+	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
 	reqsk_put(req);
 	return 0;
=20
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_s=
ock.c
index d81f74ce0f02..045d0701acfd 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -1123,12 +1123,16 @@ static void reqsk_timer_handler(struct timer_list=
 *t)
 }
=20
 static void reqsk_queue_hash_req(struct request_sock *req,
-				 unsigned long timeout)
+				 unsigned long timeout, bool *found_dup_sk)
 {
+	inet_ehash_insert(req_to_sk(req), NULL, found_dup_sk);
+	if (found_dup_sk && *found_dup_sk)
+		return;
+
+	/* The timer needs to be setup after a successful insertion. */
 	timer_setup(&req->rsk_timer, reqsk_timer_handler, TIMER_PINNED);
 	mod_timer(&req->rsk_timer, jiffies + timeout);
=20
-	inet_ehash_insert(req_to_sk(req), NULL, NULL);
 	/* before letting lookups find us, make sure all req fields
 	 * are committed to memory and refcnt initialized.
 	 */
@@ -1137,9 +1141,12 @@ static void reqsk_queue_hash_req(struct request_so=
ck *req,
 }
=20
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock =
*req,
-				   unsigned long timeout)
+				   unsigned long timeout, bool *found_dup_sk)
 {
-	reqsk_queue_hash_req(req, timeout);
+	reqsk_queue_hash_req(req, timeout, found_dup_sk);
+	if (found_dup_sk && *found_dup_sk)
+		return;
+
 	inet_csk_reqsk_queue_added(sk);
 }
 EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9c04a9c8be9d..49876477c2b9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -7255,8 +7255,17 @@ int tcp_conn_request(struct request_sock_ops *rsk_=
ops,
 	} else {
 		tcp_rsk(req)->tfo_listener =3D false;
 		if (!want_cookie) {
+			bool found_dup_sk =3D false;
+
 			req->timeout =3D tcp_timeout_init((struct sock *)req);
-			inet_csk_reqsk_queue_hash_add(sk, req, req->timeout);
+			inet_csk_reqsk_queue_hash_add(sk, req, req->timeout,
+						      &found_dup_sk);
+
+			if (unlikely(found_dup_sk)) {
+				reqsk_free(req);
+				return 0;
+			}
+
 		}
 		af_ops->send_synack(sk, dst, &fl, req, &foc,
 				    !want_cookie ? TCP_SYNACK_NORMAL :
--=20
2.25.1

