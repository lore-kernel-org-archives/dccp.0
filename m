From: David Miller <davem@davemloft.net>
Date: Sun, 13 Apr 2008 01:35:58 +0000
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Message-Id: <20080412.183558.100508594.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <47F61B5C.8090105@trash.net>
In-Reply-To: <47F61B5C.8090105@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 11 Apr 2008 11:05:01 -0300

> Em Fri, Apr 11, 2008 at 04:03:10PM +0200, Patrick McHardy escreveu:
> > Gerrit Renker wrote:
> >>>>>     [DCCP]: Fix skb->cb conflicts with IP
> >>>>>         dev_queue_xmit() and the other IP output functions expect to 
> >> <snip>
> >>> Dave, I'm not sure whether you've missed this or expect it
> >>> to go through Arnaldo, just want to make sure it doesn't
> >>> get missed because of a misunderstanding :)
> >>>
> >>>
> >> If it is not too much work, can you please also remove the two attached
> >> hunks which are now redundant thanks to the above patch.
> >
> >
> > I've added it to the patch, thanks.
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Applied to net-2.6, thanks everyone.
