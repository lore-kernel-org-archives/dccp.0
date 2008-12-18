From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 18 Dec 2008 10:55:02 +0000
Subject: Re: [RFC][PATCH] static builtin CCIDs was  Re: [PATCH 2/5] dccp:
Message-Id: <20081218105502.GA21653@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20081217183041.GW14518@ghostprotocols.net>
In-Reply-To: <20081217183041.GW14518@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Dec 18, 2008 at 06:41:10AM +0100, Gerrit Renker escreveu:
> Quoting Arnaldo:
> | Em Wed, Dec 17, 2008 at 04:20:38PM -0200, Arnaldo Carvalho de Melo escreveu:
> | > > IOW we're back to my suggestion on looking at
> | > > tcp_set_congestion_control(). :-)
> | > 
> | > I tried to test this using ttcp over loopback but the tree seems broken
> | > somehow, with or without this patch I'm getting:
> | > 
> | > Could not activate 0 at /home/acme/git/net-next-2.6/net/dccp/feat.c:1176
> | > 
> | > I tried doing a quick chase on this one but failed miserably, Gerrit,
> | > any ideas?
> | 
> | Well, without the patch the problem was that dccp_ccid2 was not being
> | autoloaded, as soon as I manually loaded it, ttcp worked. Now to see
> | why...
> I have acked your patch but haven't had time to compile and test it.
> Will do this in due course and integrate it into the test tree. 
> 
> With regard to the error message, this says that the feature with index 0
> could not be activated. According to table 6.4 in RFC 4340 this is a bug

I figured that out later, after some more tweaking and systemtapping it
ended up with index 5 failing and that was the ackvec code that was not
being included, just the stubs that always return NULL on the allocation
routine, after that was fixed by removing CONFIG_IP_DCCP_ACKVEC, i.e.
always including that code since CCID2 now is always included, all
worked with a simple, over loopback, ttcp test.

> because it tries to activate a reserved feature.
 
> Will do in-depth testing later on today.

Thanks!

- Arnaldo
