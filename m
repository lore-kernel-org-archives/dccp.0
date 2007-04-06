From: Brian Haley <brian.haley@hp.com>
Date: Fri, 06 Apr 2007 03:19:25 +0000
Subject: [PATCH 0/4] [IPv6] Add new scope and address type inlines
Message-Id: <4615BC3D.8010803@hp.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[sorry if anyone got these multiple times, git-send-email weirdness]

This set of patches adds new IPv6 scope and address type inlines
to both clean-up the code (inspired by Arnaldo's skb cleanup) and reduce
calls to ipv6_addr_type() when we can just compare the address directly.
No functionality is changed.

I'm only cc'ing the DCCP and LkSCTP lists on the patches that actually
touch their code.

-Brian

