From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 16 Oct 2007 09:22:57 +0000
Subject: Re: [patch] net/DCCP: fix link error with !CONFIG_SYSCTL
Message-Id: <200710161022.57708@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ingo Molnar:
|  Subject: net/DCCP: fix link error with !CONFIG_SYSCTL
|  
|  do not define the sysctl_dccp_sync_ratelimit sysctl variable in
|  the CONFIG_SYSCTL dependent sysctl.c module - move it to input.c instead.
|  
|  this fixes the following build bug:
|  
|   net/built-in.o: In function `dccp_check_seqno':
|   input.c:(.text+0xbd859): undefined reference to `sysctl_dccp_sync_ratelimit'

[thanks for spotting, copied this to dccp@vger instead of linux-kernel]

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

NB: Arnaldo, in the test tree this problem is fixed and may serve as a suitable solution 
    for other sysctl variables also: the variables are always present, the #error wrapper
    has been replaced by an #ifdef, and the dccp-$(CONFIG_SYSCTL) += sysctl.o in the Makefile
    has been shifted to dccp-y; so that the variables are always there, independent of whether 
    CONFIG_SYSCTL is enabled.
 
|  +++ linux/net/dccp/sysctl.c
|  @@ -18,9 +18,6 @@
|   #error This file should not be compiled without CONFIG_SYSCTL defined
    ^
    +------------------ this #error has been replaced by a wrapper
