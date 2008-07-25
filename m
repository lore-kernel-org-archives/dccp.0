From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 25 Jul 2008 02:33:40 +0000
Subject: [PATCHv2 0/4] Fix check for incorrect or missing sequence mumbers
Message-Id: <48893B84.8060709@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch fix the incorrect or missing sequence mumbers in ICMP
message, add the check for incorrect or missing sequence mumbers in
ICMPv6 message.


[PATCHv2 1/4] DCCP: Fix to check the sequence number in ICMP message correctly
[PATCHv2 2/4] DCCP: Add check for sequence number in ICMPv6 message
[PATCHv2 3/4] DCCP: Fix to check missing sequence number for ICMP message correctly
[PATCHv2 4/4] DCCP: Add check for missing sequence number in ICMPv6 message

