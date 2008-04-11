From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Fri, 11 Apr 2008 10:24:06 +0000
Subject: [PATCH 0/5] [DCCP]: Queuing policies
Message-Id: <200804111224.06958.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is resubmission of queuing policy related patches for DCCP. Queuing 
policies allow userspace applications to more effectively use DCCP. Changes 
include:
 - CodingStyle,
 - do not allow applications to change qpolicy after accept or connect,
 - naming changes,
 - make dccps_qpolicy a non-pointer,
 - include dccpd_policy in dccp_skb_cb as a structure not char[16].
-- 
Regards,
Tomasz Grobelny
