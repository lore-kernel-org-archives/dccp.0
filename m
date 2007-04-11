From: Patrick McHardy <kaber@trash.net>
Date: Wed, 11 Apr 2007 09:22:00 +0000
Subject: Re: [PATCH 4/5]: Rate-limit DCCP-Syncs
Message-Id: <461CA8B8.8040501@trash.net>
List-Id: <dccp.vger.kernel.org>
References: <200704091058.57313@strip-the-willow>
In-Reply-To: <200704091058.57313@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> Quoting Ian McDonald:
> |  No, no, no. A userspace parameter in jiffies is just wrong I think.
> |  You change HZ and this doesn't automatically change. You could be
> |  doing this with different kernels on your machine even and setting
> |  sysctls in a file. Take a bit of time and put this in milliseconds.
> The default value is set at compilation time when HZ is known. I used jiffies for the
> main reason to make this sysctl consistent with the other, similar, runtime variables
> which are also in units of jiffies (cf. Documentation/networking/ip-sysctl.txt):
> 
>  * inet_peer_minttl / inet_peer_maxttl / inet_peer_gc_mintime / inet_peer_gc_maxtime


Actually these are in seconds, they use proc_dointvec_jiffies, which
takes seconds and converts to jiffies.

>  * icmp_ratelimit - which is semantically the closest to this sysctl


This unfortunately really is in jiffies.

> Would you still rather have this in milliseconds?


I agree with Ian that userspace interfaces should use fixed units that
don't depend on compile-time options.
