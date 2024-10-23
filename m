Received: from forward202d.mail.yandex.net (forward202d.mail.yandex.net [178.154.239.219])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF5523FD4;
	Wed, 23 Oct 2024 12:16:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=178.154.239.219
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1729685792; cv=none; b=dJKPziwNBmESrn3xPFl+johO45z7f1M8f2BLnauhaLE3VN/9dusmyLN0Vo71IW7M8Mk/HONHTwkGq1hfWm8iQToV08Zgkk1vu5JfR9aidq6ydf6CPpuGZyiGAoL53fGmU4wAhUjsRTunKA2rJS7r+kCbVeVVqmkw5FZH5IKclG8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1729685792; c=relaxed/simple;
	bh=aXN8sAgjP8tJUvbUcasQkihVCUtYgWcfLcpta+klIvc=;
	h=Message-ID:Date:MIME-Version:To:Cc:From:Subject:Content-Type; b=OprcgS8MkGUhnmlW13VTkOwzUnNSOH9TLHp09OmZ1fZjjbQe2ffS2iFE1pZSlrXXhg8hHOnlD3ZsED8KiCWPlnG5eJ9ulRiH9V1rkTpMLufDD5CM6FVvmsaxkswvJQOA/iu85Qmo9sKA4d1M0dekuiD1AFvcKfff+ip6hlVj3wg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=yandex.ru; spf=pass smtp.mailfrom=yandex.ru; dkim=pass (1024-bit key) header.d=yandex.ru header.i=@yandex.ru header.b=Z9nhH028; arc=none smtp.client-ip=178.154.239.219
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=yandex.ru
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=yandex.ru
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex.ru header.i=@yandex.ru header.b="Z9nhH028"
Received: from forward103d.mail.yandex.net (forward103d.mail.yandex.net [IPv6:2a02:6b8:c41:1300:1:45:d181:d103])
	by forward202d.mail.yandex.net (Yandex) with ESMTPS id D3EA2648A1;
	Wed, 23 Oct 2024 15:10:10 +0300 (MSK)
Received: from mail-nwsmtp-smtp-production-main-95.klg.yp-c.yandex.net (mail-nwsmtp-smtp-production-main-95.klg.yp-c.yandex.net [IPv6:2a02:6b8:c42:874b:0:640:bc97:0])
	by forward103d.mail.yandex.net (Yandex) with ESMTPS id E648D6094A;
	Wed, 23 Oct 2024 15:10:02 +0300 (MSK)
Received: by mail-nwsmtp-smtp-production-main-95.klg.yp-c.yandex.net (smtp/Yandex) with ESMTPSA id x9Salw7GVKo0-3BakgMN8;
	Wed, 23 Oct 2024 15:10:01 +0300
X-Yandex-Fwd: 1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex.ru; s=mail;
	t=1729685402; bh=ZcOtQUqg01lkwotzQHgXDdo/t212Pa4kKdWpmZhhtzM=;
	h=Subject:To:From:Cc:Date:Message-ID;
	b=Z9nhH028GmZ0o5UEdNtkAsF2lQSuITF3nD+43gbsrNpyn4dFYkhWwam79qLIREUjd
	 uOyR2U84f5sOSOvg+Ikm160QdssVa3A7U8y98239Ay3qtRE1B9QZjTBL23vLRRbwgl
	 iICr5C1rDJSzDyN87nWF9zksP6mEeAmwT1lx+xr4=
Authentication-Results: mail-nwsmtp-smtp-production-main-95.klg.yp-c.yandex.net; dkim=pass header.i=@yandex.ru
Message-ID: <938106e0-269a-4d5a-995f-2314fecedb3a@yandex.ru>
Date: Wed, 23 Oct 2024 15:09:59 +0300
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Content-Language: en-US
To: Kuniyuki Iwashima <kuniyu@amazon.com>
Cc: dccp@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 syzbot+554ccde221001ab5479a@syzkaller.appspotmail.com
From: Dmitry Antipov <dmantipov@yandex.ru>
Subject: Re: KASAN: use-after-free Read in ccid2_hc_tx_packet_recv
Autocrypt: addr=dmantipov@yandex.ru; keydata=
 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
 A/UwwXBRuvydGV0=
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Looking through https://syzkaller.appspot.com/bug?extid=554ccde221001ab5479a,
I've found the problem which may be illustrated with the following patch:

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 5926159a6f20..eb551872170c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -678,6 +678,7 @@ int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)

         if (sk->sk_state == DCCP_OPEN) { /* Fast path */
                 if (dccp_rcv_established(sk, skb, dh, skb->len))
+                       /* Go to reset here */
                         goto reset;
                 return 0;
         }
@@ -712,6 +713,7 @@ int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)

  reset:
         dccp_v4_ctl_send_reset(sk, skb, SK_RST_REASON_NOT_SPECIFIED);
+       /* Freeing skb may leave dangling pointers in ack vectors */
         kfree_skb(skb);
         return 0;
  }

I'm not an expert with DCCP protocol innards and have no idea whether ack
vectors still needs to be processed after sending reset. But if it is so,
the solution might be to copy all of the data from the relevant skbs instead
of just saving the pointers, e.g.:

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 1cba001bb4c8..24c6ad06d896 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -347,17 +347,18 @@ void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno)
  }

  /*
- *	Routines to keep track of Ack Vectors received in an skb
+ *	Routines to keep track of Ack Vectors copied from the received skb
   */
  int dccp_ackvec_parsed_add(struct list_head *head, u8 *vec, u8 len, u8 nonce)
  {
-	struct dccp_ackvec_parsed *new = kmalloc(sizeof(*new), GFP_ATOMIC);
-
+	struct dccp_ackvec_parsed *new = kmalloc(struct_size(new, vec, len),
+						 GFP_ATOMIC);
  	if (new == NULL)
  		return -ENOBUFS;
-	new->vec   = vec;
-	new->len   = len;
+
+	new->len = len;
  	new->nonce = nonce;
+	memcpy(new->vec, vec, len);

  	list_add_tail(&new->node, head);
  	return 0;
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index d2c4220fb377..491fd587de90 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -117,18 +117,18 @@ static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)

  /**
   * struct dccp_ackvec_parsed  -  Record offsets of Ack Vectors in skb
- * @vec:	start of vector (offset into skb)
+ * @vec:	contents of ack vector (copied from skb)
   * @len:	length of @vec
   * @nonce:	whether @vec had an ECN nonce of 0 or 1
   * @node:	FIFO - arranged in descending order of ack_ackno
   *
- * This structure is used by CCIDs to access Ack Vectors in a received skb.
+ * This structure is used by CCIDs to access Ack Vectors from the received skb.
   */
  struct dccp_ackvec_parsed {
-	u8		 *vec,
-			 len,
-			 nonce:1;
  	struct list_head node;
+	u8 len;
+	u8 nonce:1;
+	u8 vec[] __counted_by(len);
  };

  int dccp_ackvec_parsed_add(struct list_head *head, u8 *vec, u8 len, u8 nonce);
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index d6b30700af67..a1f2da3c4fa9 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -589,14 +589,15 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
  	/* go through all ack vectors */
  	list_for_each_entry(avp, &hc->tx_av_chunks, node) {
  		/* go through this ack vector */
-		for (; avp->len--; avp->vec++) {
+		u8 *v;
+		for (v = avp->vec; v < avp->vec + avp->len--; v++) {
  			u64 ackno_end_rl = SUB48(ackno,
-						 dccp_ackvec_runlen(avp->vec));
+						 dccp_ackvec_runlen(v));

  			ccid2_pr_debug("ackvec %llu |%u,%u|\n",
  				       (unsigned long long)ackno,
-				       dccp_ackvec_state(avp->vec) >> 6,
-				       dccp_ackvec_runlen(avp->vec));
+				       dccp_ackvec_state(v) >> 6,
+				       dccp_ackvec_runlen(v));
  			/* if the seqno we are analyzing is larger than the
  			 * current ackno, then move towards the tail of our
  			 * seqnos.
@@ -615,7 +616,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
  			 * run length
  			 */
  			while (between48(seqp->ccid2s_seq,ackno_end_rl,ackno)) {
-				const u8 state = dccp_ackvec_state(avp->vec);
+				const u8 state = dccp_ackvec_state(v);

  				/* new packet received or marked */
  				if (state != DCCPAV_NOT_RECEIVED &&

Comments are highly appreciated.

Dmitry
