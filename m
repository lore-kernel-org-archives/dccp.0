From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Apr 2007 09:35:04 +0000
Subject: Re: [PATCH 4/5]: Rate-limit DCCP-Syncs
Message-Id: <200704111035.04456@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704091058.57313@strip-the-willow>
In-Reply-To: <200704091058.57313@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > The default value is set at compilation time when HZ is known. I used jiffies for the
|  > main reason to make this sysctl consistent with the other, similar, runtime variables
|  > which are also in units of jiffies (cf. Documentation/networking/ip-sysctl.txt):
|  > 
|  >  * inet_peer_minttl / inet_peer_maxttl / inet_peer_gc_mintime / inet_peer_gc_maxtime
|  
|  Actually these are in seconds, they use proc_dointvec_jiffies, which
|  takes seconds and converts to jiffies.
I haven't looked at the code - it may be that the information in ip-sysctl.txt is outdated.
  
<snip>
|  I agree with Ian that userspace interfaces should use fixed units that
|  don't depend on compile-time options.
|  
Ok,  will convert patch & Documentation to use milliseconds, and send an update later.

Thank you for the input.
