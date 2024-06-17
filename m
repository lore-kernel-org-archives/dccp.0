Received: from mailgw.kylinos.cn (mailgw.kylinos.cn [124.126.103.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6CB919005D;
	Mon, 17 Jun 2024 07:56:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=124.126.103.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718611016; cv=none; b=i1zI2ctnY/NK65heQyEcUMsGn7fFthXvb4K+AaQ/QHtsj94RCpROgrnXVOR5bwk2i28FmN91x+Z1Lyc+HTlnsED0GyEkhVeVIgRiS6I4ACVssKbCX1ibnmBGOUf88qrtnDkhPjIZEhsiZN+mWB5+aK9CEyIIbtwY4cobzTwGqC8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718611016; c=relaxed/simple;
	bh=MYjaPWxvd0zWSAPoX2STJiQiDpNqeno+Fw71ehmaaAE=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=V/nJqWfT4TJ3e879mINDh6CpXxP+8atzwxK19oygoO7K+L6vLkxhbwcAtUc7OJhGpOSAlfXaeX/Ix+xxJ1Cgw8Mx7M6JE1Ccy7qpWr+nTvfoTPx5ZhXKSa/rR/T6tzN8Wtl8NFz04/ZccjFtKDltB1r6E1mc6voZljEXBjJdgZg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn; spf=pass smtp.mailfrom=kylinos.cn; arc=none smtp.client-ip=124.126.103.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kylinos.cn
X-UUID: 241da90a2c7f11ef9305a59a3cc225df-20240617
X-CID-P-RULE: Release_Ham
X-CID-O-INFO: VERSION:1.1.38,REQID:edb0b905-6b20-4754-b49c-d4320a87b90d,IP:10,
	URL:0,TC:0,Content:-25,EDM:-25,RT:0,SF:-15,FILE:0,BULK:0,RULE:Release_Ham,
	ACTION:release,TS:-55
X-CID-INFO: VERSION:1.1.38,REQID:edb0b905-6b20-4754-b49c-d4320a87b90d,IP:10,UR
	L:0,TC:0,Content:-25,EDM:-25,RT:0,SF:-15,FILE:0,BULK:0,RULE:EDM_GE969F26,A
	CTION:release,TS:-55
X-CID-META: VersionHash:82c5f88,CLOUDID:e36f6093ae4c588f80860c67b85a17f9,BulkI
	D:240617155646E5UZ8R2Y,BulkQuantity:0,Recheck:0,SF:17|19|44|66|24|102,TC:n
	il,Content:0,EDM:1|19,IP:-2,URL:0,File:nil,RT:nil,Bulk:nil,QS:nil,BEC:nil,
	COL:0,OSI:0,OSA:0,AV:0,LES:1,SPR:NO,DKR:0,DKP:0,BRR:0,BRE:0
X-CID-BVR: 0
X-CID-BAS: 0,_,0,_
X-CID-FACTOR: TF_CID_SPAM_SNR,TF_CID_SPAM_FAS,TF_CID_SPAM_FSD,TF_CID_SPAM_FSI
X-UUID: 241da90a2c7f11ef9305a59a3cc225df-20240617
Received: from node2.com.cn [(39.156.73.10)] by mailgw.kylinos.cn
	(envelope-from <luoxuanqiang@kylinos.cn>)
	(Generic MTA)
	with ESMTP id 218619999; Mon, 17 Jun 2024 15:56:45 +0800
Received: from node2.com.cn (localhost [127.0.0.1])
	by node2.com.cn (NSMail) with SMTP id A31C0B80758A;
	Mon, 17 Jun 2024 15:56:44 +0800 (CST)
X-ns-mid: postfix-666FEC3C-52643062
Received: from localhost.localdomain (unknown [10.42.12.252])
	by node2.com.cn (NSMail) with ESMTPA id A7BA1B80758A;
	Mon, 17 Jun 2024 07:56:40 +0000 (UTC)
From: luoxuanqiang <luoxuanqiang@kylinos.cn>
To: edumazet@google.com
Cc: kuniyu@amazon.com,
	davem@davemloft.net,
	dccp@vger.kernel.org,
	dsahern@kernel.org,
	fw@strlen.de,
	kuba@kernel.org,
	linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	pabeni@redhat.com,
	alexandre.ferrieux@orange.com
Subject: [PATCH net v3] Fix race for duplicate reqsk on identical SYN
Date: Mon, 17 Jun 2024 15:56:40 +0800
Message-Id: <20240617075640.207570-1-luoxuanqiang@kylinos.cn>
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
 include/net/inet_connection_sock.h |  4 ++--
 net/dccp/ipv4.c                    |  2 +-
 net/dccp/ipv6.c                    |  2 +-
 net/ipv4/inet_connection_sock.c    | 19 +++++++++++++------
 net/ipv4/tcp_input.c               |  9 ++++++++-
 5 files changed, 25 insertions(+), 11 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connec=
tion_sock.h
index 7d6b1254c92d..8ebab6220dbc 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -263,8 +263,8 @@ struct dst_entry *inet_csk_route_child_sock(const str=
uct sock *sk,
 struct sock *inet_csk_reqsk_queue_add(struct sock *sk,
 				      struct request_sock *req,
 				      struct sock *child);
-void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock =
*req,
-				   unsigned long timeout);
+bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock =
*req,
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
index d81f74ce0f02..2fa9b33ae26a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -1122,25 +1122,32 @@ static void reqsk_timer_handler(struct timer_list=
 *t)
 	inet_csk_reqsk_queue_drop_and_put(oreq->rsk_listener, oreq);
 }
=20
-static void reqsk_queue_hash_req(struct request_sock *req,
-				 unsigned long timeout)
+static bool reqsk_queue_hash_req(struct request_sock *req,
+				 unsigned long timeout, bool *found_dup_sk)
 {
+	if (!inet_ehash_insert(req_to_sk(req), NULL, found_dup_sk))
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
-				   unsigned long timeout)
+bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock =
*req,
+				   unsigned long timeout, bool *found_dup_sk)
 {
-	reqsk_queue_hash_req(req, timeout);
+	if (!reqsk_queue_hash_req(req, timeout, found_dup_sk))
+		return false;
+
 	inet_csk_reqsk_queue_added(sk);
+	return true;
 }
 EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9c04a9c8be9d..e006c374f781 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -7255,8 +7255,15 @@ int tcp_conn_request(struct request_sock_ops *rsk_=
ops,
 	} else {
 		tcp_rsk(req)->tfo_listener =3D false;
 		if (!want_cookie) {
+			bool found_dup_sk =3D false;
+
 			req->timeout =3D tcp_timeout_init((struct sock *)req);
-			inet_csk_reqsk_queue_hash_add(sk, req, req->timeout);
+			if (unlikely(!inet_csk_reqsk_queue_hash_add(sk, req, req->timeout,
+								    &found_dup_sk))) {
+				reqsk_free(req);
+				return 0;
+			}
+
 		}
 		af_ops->send_synack(sk, dst, &fl, req, &foc,
 				    !want_cookie ? TCP_SYNACK_NORMAL :
--=20
2.25.1

