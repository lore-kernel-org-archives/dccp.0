From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Wed, 15 Feb 2006 08:56:37 +0000
Subject: Re: [PATCH 1/1]: [CCID2]: Fix the use of the RTO timer
Message-Id: <20060215085636.GA15201@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <20060215013015.GA14878@tribal.sorbonet.org>
In-Reply-To: <20060215013015.GA14878@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Feb 15, 2006 at 02:44:53PM +1300, Ian McDonald wrote:
> This patch looks good in itself but there are further problems
> unloading than this as it occurs also with the code base prior to
> CCID2 merging....

Do you have specific examples?  I've been fighting quite a lot in trying to get
the module to unload itself cleanly =D

You probably are already aware that there is a reference count kept for timewait
sockets and for the control sock.  But that is not an issue.  

The only outstanding bug I can think of, which will not cause the module to
unload, is that connect race condition thing I've been bragging about.
Basically, if I recall correctly, the connection occurs and terminates before
sys_connect() returns, and the socket is never freed.
