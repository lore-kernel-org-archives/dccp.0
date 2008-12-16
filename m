From: David Miller <davem@davemloft.net>
Date: Tue, 16 Dec 2008 23:11:51 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081216.151151.220977047.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 16 Dec 2008 20:25:59 -0200

> Em Tue, Dec 16, 2008 at 01:32:00PM -0800, David Miller escreveu:
> > From: Arnaldo Carvalho de Melo <acme@redhat.com>
> > Date: Tue, 16 Dec 2008 09:19:08 -0200
> > 
> > Whereas the DCCP case is right in the connection creation fast path
> > and unconditionally executes, because it is trying to figure out what
> > CCID algorithms it can advertise.
> 
> Well, there must be some way to locklessly advertise what was previously
> loaded (and thus can't ever be unloaded).

This gets us back to my original objection.

Can these things be unloaded?  If not, and they get unconditionally
all loaded up on the first DCCP connection, why make them seperate
modules at all?

If they can get unloaded, then you need synchronization.

I would recommend that everything gets built into dccp.ko
and thus the table is fixed and never changes and thus no
locking nor any of this funny mod loading is needed at all.
