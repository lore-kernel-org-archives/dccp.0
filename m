Received: from mx0a-0031df01.pphosted.com (mx0a-0031df01.pphosted.com [205.220.168.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A8BDD66B5E;
	Sun,  5 May 2024 20:09:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=205.220.168.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1714939782; cv=none; b=MjqNax3ogeo4UoMjALs8UEgc4/zl0k6jGD0pcp02BgIBdp04xDO9amVyYZDkSd8Upbrir09RXTA8UHsE1SiQM/5UWtErJvZPwGpag7YFId/ju2hfpdInF6xRkdWaCGxMsCUwCuHySWbNyzCIxr+pbgimcBoQM6W7FKiFExX2iZI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1714939782; c=relaxed/simple;
	bh=l0Is6svymKjamH4uZS0/HWAPWOtqAeuFISJUmCiMhqg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-ID:To:CC; b=XV8wXfTNLUcLC5kfhbKYOrSGi2UQRAqWSurGnBKhcnDn3gzv0b6u7EZvoaCQxWQzTzo94R2UKWTmmEwfG11pIetqGA1NnOZ8upvDP7+wdgflXjlAWE3ocwEOHo6xxRCmyL5kDeo62PdcR1gNiLnKbXEzaDyvuXXaXwgoJTbvLLU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=quicinc.com; spf=pass smtp.mailfrom=quicinc.com; dkim=pass (2048-bit key) header.d=quicinc.com header.i=@quicinc.com header.b=psmaQEc7; arc=none smtp.client-ip=205.220.168.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=quicinc.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=quicinc.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=quicinc.com header.i=@quicinc.com header.b="psmaQEc7"
Received: from pps.filterd (m0279866.ppops.net [127.0.0.1])
	by mx0a-0031df01.pphosted.com (8.18.1.2/8.18.1.2) with ESMTP id 445Jr06L007852;
	Sun, 5 May 2024 20:09:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=quicinc.com; h=
	from:date:subject:mime-version:content-type
	:content-transfer-encoding:message-id:to:cc; s=qcppdkim1; bh=dhI
	dUAuP7SIFps+tLvU0oNcUTcpH05sfx3iIi6J+ck8=; b=psmaQEc7B6frIL0kfKL
	dvlIOCpSKTJBce8eljit4k6nxXXWS0eNqKQ76iFVhcsS4pNQYPYXhqZaiIr8Ec7m
	rpl0OeJJ/P8k6UgBXEEtNk6wkSL5OL1mudziQ8V5ckSAt/s24BHRIpcXziJUtMo+
	2q+mYfeijXnXXYNoSF/IrkaTbH55ju9l0hPM3A+l4xO0Yj0U2exoGnGfoCtYAso5
	YmiVbadbg/m2uTNbBJo0PdKtRFnm7nyLtNTnucrF2JCs2kAJW2AJ45Y/ndZnQUSe
	NhdBejozC1gsB3DwDTpRNQM1qENLe6i7sxxhWPXlWJPsUwoOz4GBnvY8WKeSuBOp
	4eQ==
Received: from nalasppmta02.qualcomm.com (Global_NAT1.qualcomm.com [129.46.96.20])
	by mx0a-0031df01.pphosted.com (PPS) with ESMTPS id 3xwead21kc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Sun, 05 May 2024 20:09:33 +0000 (GMT)
Received: from nalasex01a.na.qualcomm.com (nalasex01a.na.qualcomm.com [10.47.209.196])
	by NALASPPMTA02.qualcomm.com (8.17.1.5/8.17.1.5) with ESMTPS id 445K9WjD020850
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Sun, 5 May 2024 20:09:32 GMT
Received: from [169.254.0.1] (10.49.16.6) by nalasex01a.na.qualcomm.com
 (10.47.209.196) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.1544.9; Sun, 5 May 2024
 13:09:32 -0700
From: Jeff Johnson <quic_jjohnson@quicinc.com>
Date: Sun, 5 May 2024 13:09:31 -0700
Subject: [PATCH] net: dccp: Fix ccid2_rtt_estimator() kernel-doc
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-ID: <20240505-ccid2_rtt_estimator-kdoc-v1-1-09231fcb9145@quicinc.com>
X-B4-Tracking: v=1; b=H4sIAHrnN2YC/x3M0QrCMAxA0V8ZeTZQ6+bEXxEZWZu6IGslKSKM/
 bvVx/Nw7wbGKmxw7TZQfotJyQ3HQwdhofxglNgM3vneDW7AECT6SWud2KqsVIviM5aA46k/p4v
 nkVKElr+Uk3z+69u9eSZjnJVyWH7Dlayywr5/AY1jhrWDAAAA
To: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet
	<edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni
	<pabeni@redhat.com>
CC: <dccp@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        Jeff Johnson <quic_jjohnson@quicinc.com>
X-Mailer: b4 0.13.0
X-ClientProxiedBy: nalasex01a.na.qualcomm.com (10.47.209.196) To
 nalasex01a.na.qualcomm.com (10.47.209.196)
X-QCInternal: smtphost
X-Proofpoint-Virus-Version: vendor=nai engine=6200 definitions=5800 signatures=585085
X-Proofpoint-GUID: 3Fggkg7K3SlZPCBekCTKWIyMZGO0QxY5
X-Proofpoint-ORIG-GUID: 3Fggkg7K3SlZPCBekCTKWIyMZGO0QxY5
X-Proofpoint-Virus-Version: vendor=baseguard
 engine=ICAP:2.0.293,Aquarius:18.0.1011,Hydra:6.0.650,FMLib:17.11.176.26
 definitions=2024-05-05_14,2024-05-03_02,2023-05-22_02
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 impostorscore=0 mlxscore=0
 lowpriorityscore=0 malwarescore=0 adultscore=0 priorityscore=1501
 mlxlogscore=830 bulkscore=0 suspectscore=0 clxscore=1011 phishscore=0
 spamscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.19.0-2404010003 definitions=main-2405050086

make C=1 reports:

warning: Function parameter or struct member 'mrtt' not described in 'ccid2_rtt_estimator'

So document the 'mrtt' parameter.

Signed-off-by: Jeff Johnson <quic_jjohnson@quicinc.com>
---
 net/dccp/ccids/ccid2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 4d9823d6dced..d6b30700af67 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -353,6 +353,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 /**
  * ccid2_rtt_estimator - Sample RTT and compute RTO using RFC2988 algorithm
  * @sk: socket to perform estimator on
+ * @mrtt: measured RTT
  *
  * This code is almost identical with TCP's tcp_rtt_estimator(), since
  * - it has a higher sampling frequency (recommended by RFC 1323),

---
base-commit: 2c4d8e19cf060744a9db466ffbaea13ab37f25ca
change-id: 20240505-ccid2_rtt_estimator-kdoc-7346f82e7afd

