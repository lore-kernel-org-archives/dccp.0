From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 08:01:39 +0000
Subject: Re: [PATCH] DCCP: Fix double free of skb which may cause kernel
Message-Id: <20080610080139.GC6169@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <484E2DC3.1030407@cn.fujitsu.com>
In-Reply-To: <484E2DC3.1030407@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Hi, Gerrit Renker
>
> Please ignore this mail, I will sent the patch again after the patch is  
> witten correctly.
>
Yes indeed - there is a valid point here but it needs a bit more investigation.

There are several paths for the control flow in dccp_v6_ctl_send_reset().
I am further wondering, since dccp_v4_ctl_send_reset() is similar, if
you can trigger the same condition in DCCPv4?

Can not test this at the moment, probably not before today.

Gerrit
