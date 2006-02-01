From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 01 Feb 2006 14:18:38 +0000
Subject: Re: feature negotiation patch for linux
Message-Id: <39e6f6c70602010618u346f216cl273776bfa0bcc9e0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/31/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> http://128.16.66.93/acme-dccp-feat.diff
>
> [no domain name because it's expiring today =( ]
>
> It's my initial "mega-patch, rough" implementation of feature negotiation for
> linux, based on acme's tree.
>
> It supports CHANGE_L, CHANGE_R via setsockopt from userland.
> It will change / confirm.
> It supports mandatory options.  [no support from userland yet though].
> It supports re-transmission of change options.
>
> TODO:
> * getsockopt to poll for option status.
> * setsockopt with a flag for mandatory options.
> * actually change the option in the protocol itself.  Until now they are only
>   negotiation and an empty function is called =D
>
>
> Any comments are welcome.  I'll try to contact acme now, and hopefully stuff
> will start getting merged.


Excellent news! First round of comments:

+	list_for_each(cur, &dp->dccps_options.dccpo_pending) {
+		opt = list_entry(cur, struct dccp_opt_pend, dccpop_list);

Please use list_for_each_entry()

dccp_feat_change should receive a gfp_t for use in kmalloc,
as it is called from setsockopt and there we should just use GFP_KERNEL.

ACK_RATIO in dccp_feat_init()? CCID2 specific stuff?

- Arnaldo
