From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 17 Dec 2008 18:30:41 +0000
Subject: Re: [RFC][PATCH] static builtin CCIDs was  Re: [PATCH 2/5] dccp:
Message-Id: <20081217183041.GW14518@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Dec 17, 2008 at 04:20:38PM -0200, Arnaldo Carvalho de Melo escreveu:
> > IOW we're back to my suggestion on looking at
> > tcp_set_congestion_control(). :-)
> 
> I tried to test this using ttcp over loopback but the tree seems broken
> somehow, with or without this patch I'm getting:
> 
> Could not activate 0 at /home/acme/git/net-next-2.6/net/dccp/feat.c:1176
> 
> I tried doing a quick chase on this one but failed miserably, Gerrit,
> any ideas?

Well, without the patch the problem was that dccp_ccid2 was not being
autoloaded, as soon as I manually loaded it, ttcp worked. Now to see
why...

- Arnaldo
