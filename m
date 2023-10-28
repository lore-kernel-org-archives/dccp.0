Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 80E2323A5;
	Sat, 28 Oct 2023 14:41:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IBa6vP9t"
Received: from mail-pl1-x642.google.com (mail-pl1-x642.google.com [IPv6:2607:f8b0:4864:20::642])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3DE12EB;
	Sat, 28 Oct 2023 07:41:43 -0700 (PDT)
Received: by mail-pl1-x642.google.com with SMTP id d9443c01a7336-1cc2f17ab26so6488225ad.0;
        Sat, 28 Oct 2023 07:41:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1698504103; x=1699108903; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=Mogg5X7d2GZ29xgOrb/+nvXHqC0JmhaLIwextb1v/14=;
        b=IBa6vP9tg1hxRM8oLhJV83O1qsSWxXMyh2OIrwTEx6AfY/vVMxOPAXZnuNfe2iKAb9
         Ra1qbqY9ycDRlwGdisGmbVn9RlNdu7cWTpBl85N6PdQv7MLvJbUnOkTTmYkZTti1ZEoA
         m/tseEEUhIia/dmuF1t2PPuR5FqRuvYpfCo7fVARC3fSCrfTbRjiBn0QNJTOofy224xe
         evJbH5J+EkF5ezzZAnl2yURr9n5qD/KBIKkaTh8ZgMw/A7dUH2O9/srI5bZ9H7t21MOe
         +B4LtqX5k/Zj7GaiMwLVbV3MbXpjY60RsfVrJGucbnrMVdT4Y0SWiOy9IyUNy+qG29W9
         r5jw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1698504103; x=1699108903;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=Mogg5X7d2GZ29xgOrb/+nvXHqC0JmhaLIwextb1v/14=;
        b=kGIdZe1NbmRFoEYqB92oBYV5nTAo0SELrbBePBRnA4/iV8QcEzLs7IyAcAImrXKyNU
         IxDKqSgSV/OwSA2hzPK7HxTKCMxuUjAhQgS/GfeAz5QDqmyqmUyaoAzQV+Q/qltDydaM
         fJnp6v9aTS7PANRb5PCEa91ufR4ulUeg3f4PboQZLZGYkmLgz2rhE2j2REMhdZ8C4S2/
         0pZH8d4xmU4pKkSOhMA71oauvdiH7hFfK+aS+7Q+8L3LruQRNMHBMVJZWUSq3C/7eSRy
         qeC6Choy5pqIomJdnj3xxbQ8UKNI7eNpcYWe5k2olxQVIUK7poWdLxg8mvi5onjkteJl
         L1+w==
X-Gm-Message-State: AOJu0Yx5NsiwWwRosdkFUKzAbfX/rv7JQPTRa3siZQGaFNhd6faikuvi
	Netr+XZHgAxCucrNiJoRz2s=
X-Google-Smtp-Source: AGHT+IE48W7C9EcGBo31JtUbLFJMzB8XIJdO4gsF13JfO+44ruwtMvSCZX/XYHWKHBom5u1Ob8s1sg==
X-Received: by 2002:a17:903:3208:b0:1cc:3e45:ac0e with SMTP id s8-20020a170903320800b001cc3e45ac0emr99555plh.69.1698504102629;
        Sat, 28 Oct 2023 07:41:42 -0700 (PDT)
Received: from localhost.localdomain ([27.4.124.129])
        by smtp.gmail.com with ESMTPSA id f15-20020a170902ce8f00b001c60a2b5c61sm3302209plg.134.2023.10.28.07.41.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 28 Oct 2023 07:41:42 -0700 (PDT)
From: Bragatheswaran Manickavel <bragathemanick0908@gmail.com>
To: davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com
Cc: Bragatheswaran Manickavel <bragathemanick0908@gmail.com>,
	dccp@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com
Subject: [PATCH net] dccp: check for ccid in ccid_hc_tx_send_packet
Date: Sat, 28 Oct 2023 20:11:36 +0530
Message-Id: <20231028144136.3462-1-bragathemanick0908@gmail.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ccid_hc_tx_send_packet might be called with a NULL ccid pointer
leading to a NULL pointer dereference

Below mentioned commit has similarly changes
commit 276bdb82dedb ("dccp: check ccid before dereferencing")

Reported-by: syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com
Closes: https://syzkaller.appspot.com/bug?extid=c71bc336c5061153b502
Signed-off-by: Bragatheswaran Manickavel <bragathemanick0908@gmail.com>
---
 net/dccp/ccid.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index 105f3734dadb..1015dc2b9392 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -163,7 +163,7 @@ static inline int ccid_packet_dequeue_eval(const int return_code)
 static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct sock *sk,
 					 struct sk_buff *skb)
 {
-	if (ccid->ccid_ops->ccid_hc_tx_send_packet != NULL)
+	if (ccid != NULL && ccid->ccid_ops->ccid_hc_tx_send_packet != NULL)
 		return ccid->ccid_ops->ccid_hc_tx_send_packet(sk, skb);
 	return CCID_PACKET_SEND_AT_ONCE;
 }
-- 
2.34.1

