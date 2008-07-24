From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 24 Jul 2008 08:43:29 +0000
Subject: [PATCH 0/4] Fix check for incorrect or missing sequence mumbers in
Message-Id: <488840B1.5070303@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch fix the incorrect or missing sequence mumbers in ICMP
message, add the check for incorrect or missing sequence mumbers in
ICMPv6 message.

[PATCH 1/4] DCCP: Fix to check the sequence number in ICMP message correctly
[PATCH 2/4] DCCP: Add check for sequence number in ICMPv6 message
[PATCH 3/4] DCCP: Fix to check missing sequence number for ICMP message correctly
[PATCH 4/4] DCCP: Add check for missing sequence number in ICMPv6 message


