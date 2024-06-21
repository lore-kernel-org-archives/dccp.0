Received: from mailgw.kylinos.cn (mailgw.kylinos.cn [124.126.103.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6273410E3;
	Fri, 21 Jun 2024 01:39:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=124.126.103.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718933990; cv=none; b=bbLNSJ81Iud/V0C13fmzJdUOw2BRC+11lbtQS6FOkD+yC9QgqaY+5rSBVJY9htrBKWuMtNpxPIB6bQ2duztVbYibYixFFaFY0r3FWd1yjUT3rP4O7HN3D9Vp/LpMVlq//14ehDwu7knHxRKjsysC9z/lb0qMsdsaAXJaDaDUqhk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718933990; c=relaxed/simple;
	bh=ylVSDJAg3VnwGnHSfLRMM20U9258dmgtowJjtoYTEUo=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=XJ4ip7hp89KC3D+U30csKAWV/qKOnGwElGfBWHmWlodyCmAh/xEJ4dxTZ+a3Qelgc/WiefuZ0tZagkQQur8bq0BhBewSsshaTkMzzjQY+gyd/5d3EZiajcwArJ/GT5I+XwECzcxl30InUwhyWEOHCVOtUJEVO7fRh/C1jUx1rNk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn; spf=pass smtp.mailfrom=kylinos.cn; arc=none smtp.client-ip=124.126.103.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kylinos.cn
X-UUID: 213de3882f6f11ef9305a59a3cc225df-20240621
X-CID-P-RULE: Release_Ham
X-CID-O-INFO: VERSION:1.1.38,REQID:751243a8-5f08-4b65-96f2-8cbda62ac60d,IP:10,
	URL:0,TC:0,Content:-25,EDM:0,RT:0,SF:-15,FILE:0,BULK:0,RULE:Release_Ham,AC
	TION:release,TS:-30
X-CID-INFO: VERSION:1.1.38,REQID:751243a8-5f08-4b65-96f2-8cbda62ac60d,IP:10,UR
	L:0,TC:0,Content:-25,EDM:0,RT:0,SF:-15,FILE:0,BULK:0,RULE:Release_Ham,ACTI
	ON:release,TS:-30
X-CID-META: VersionHash:82c5f88,CLOUDID:5096c713223ac34296952acfad85d7cd,BulkI
	D:2406210939427IK7KIMX,BulkQuantity:0,Recheck:0,SF:24|17|19|44|66|38|102,T
	C:nil,Content:0,EDM:-3,IP:-2,URL:0,File:nil,RT:nil,Bulk:nil,QS:nil,BEC:nil
	,COL:0,OSI:0,OSA:0,AV:0,LES:1,SPR:NO,DKR:0,DKP:0,BRR:0,BRE:0
X-CID-BVR: 0,NGT
X-CID-BAS: 0,NGT,0,_
X-CID-FACTOR: TF_CID_SPAM_SNR,TF_CID_SPAM_FAS,TF_CID_SPAM_FSD,TF_CID_SPAM_FSI
X-UUID: 213de3882f6f11ef9305a59a3cc225df-20240621
Received: from node2.com.cn [(39.156.73.10)] by mailgw.kylinos.cn
	(envelope-from <luoxuanqiang@kylinos.cn>)
	(Generic MTA)
	with ESMTP id 945668833; Fri, 21 Jun 2024 09:39:41 +0800
Received: from node2.com.cn (localhost [127.0.0.1])
	by node2.com.cn (NSMail) with SMTP id 49FE7B803C9E;
	Fri, 21 Jun 2024 09:39:31 +0800 (CST)
X-ns-mid: postfix-6674D9D2-981081146
Received: from localhost.localdomain (unknown [10.42.12.252])
	by node2.com.cn (NSMail) with ESMTPA id 57C29B803C9D;
	Fri, 21 Jun 2024 01:39:30 +0000 (UTC)
From: luoxuanqiang <luoxuanqiang@kylinos.cn>
To: kuniyu@amazon.com,
	edumazet@google.com,
	kuba@kernel.org,
	davem@davemloft.net,
	pabeni@redhat.com
Cc: dccp@vger.kernel.org,
	dsahern@kernel.org,
	fw@strlen.de,
	linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	alexandre.ferrieux@orange.com
Subject: [PATCH net v4] Fix race for duplicate reqsk on identical SYN
Date: Fri, 21 Jun 2024 09:39:29 +0800
Message-Id: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
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
Add a return value to inet_csk_reqsk_queue_hash_add() to confirm if the
ehash insertion is successful (Up to now, the reason for unsuccessful
insertion is that a reqsk for the same connection has already been
inserted). If the insertion fails, release the reqsk.

Due to the refcnt, Kuniyuki suggests also adding a return value check
for the DCCP module; if ehash insertion fails, indicating a successful
insertion of the same connection, simply release the reqsk as well.

Simultaneously, In the reqsk_queue_hash_req(), the start of the
req->rsk_timer is adjusted to be after successful insertion.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: luoxuanqiang <luoxuanqiang@kylinos.cn>
---
 include/net/inet_connection_sock.h |  2 +-
 net/dccp/ipv4.c                    |  7 +++++--
 net/dccp/ipv6.c                    |  7 +++++--
 net/ipv4/inet_connection_sock.c    | 17 +++++++++++++----
 net/ipv4/tcp_input.c               |  7 ++++++-
 5 files changed, 30 insertions(+), 10 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connec=
tion_sock.h
index 7d6b1254c92d..c0deaafebfdc 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -263,7 +263,7 @@ struct dst_entry *inet_csk_route_child_sock(const str=
uct sock *sk,
 struct sock *inet_csk_reqsk_queue_add(struct sock *sk,
 				      struct request_sock *req,
 				      struct sock *child);
-void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock =
*req,
+bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock =
*req,
 				   unsigned long timeout);
 struct sock *inet_csk_complete_hashdance(struct sock *sk, struct sock *c=
hild,
 					 struct request_sock *req,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ff41bd6f99c3..5926159a6f20 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -657,8 +657,11 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_=
buff *skb)
 	if (dccp_v4_send_response(sk, req))
 		goto drop_and_free;
=20
-	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
-	reqsk_put(req);
+	if (unlikely(!inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT)=
))
+		reqsk_free(req);
+	else
+		reqsk_put(req);
+
 	return 0;
=20
 drop_and_free:
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 85f4b8fdbe5e..da5dba120bc9 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -400,8 +400,11 @@ static int dccp_v6_conn_request(struct sock *sk, str=
uct sk_buff *skb)
 	if (dccp_v6_send_response(sk, req))
 		goto drop_and_free;
=20
-	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
-	reqsk_put(req);
+	if (unlikely(!inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT)=
))
+		reqsk_free(req);
+	else
+		reqsk_put(req);
+
 	return 0;
=20
 drop_and_free:
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_s=
ock.c
index d81f74ce0f02..d4f0eff8b20f 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -1122,25 +1122,34 @@ static void reqsk_timer_handler(struct timer_list=
 *t)
 	inet_csk_reqsk_queue_drop_and_put(oreq->rsk_listener, oreq);
 }
=20
-static void reqsk_queue_hash_req(struct request_sock *req,
+static bool reqsk_queue_hash_req(struct request_sock *req,
 				 unsigned long timeout)
 {
+	bool found_dup_sk =3D false;
+
+	if (!inet_ehash_insert(req_to_sk(req), NULL, &found_dup_sk))
+		return false;
+
+	/* The timer needs to be setup after a successful insertion. */
 	timer_setup(&req->rsk_timer, reqsk_timer_handler, TIMER_PINNED);
 	mod_timer(&req->rsk_timer, jiffies + timeout);
=20
-	inet_ehash_insert(req_to_sk(req), NULL, NULL);
 	/* before letting lookups find us, make sure all req fields
 	 * are committed to memory and refcnt initialized.
 	 */
 	smp_wmb();
 	refcount_set(&req->rsk_refcnt, 2 + 1);
+	return true;
 }
=20
-void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock =
*req,
+bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock =
*req,
 				   unsigned long timeout)
 {
-	reqsk_queue_hash_req(req, timeout);
+	if (!reqsk_queue_hash_req(req, timeout))
+		return false;
+
 	inet_csk_reqsk_queue_added(sk);
+	return true;
 }
 EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9c04a9c8be9d..c6b08a43ce00 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -7256,7 +7256,12 @@ int tcp_conn_request(struct request_sock_ops *rsk_=
ops,
 		tcp_rsk(req)->tfo_listener =3D false;
 		if (!want_cookie) {
 			req->timeout =3D tcp_timeout_init((struct sock *)req);
-			inet_csk_reqsk_queue_hash_add(sk, req, req->timeout);
+			if (unlikely(!inet_csk_reqsk_queue_hash_add(sk, req,
+								    req->timeout))) {
+				reqsk_free(req);
+				return 0;
+			}
+
 		}
 		af_ops->send_synack(sk, dst, &fl, req, &foc,
 				    !want_cookie ? TCP_SYNACK_NORMAL :
--=20
2.25.1

