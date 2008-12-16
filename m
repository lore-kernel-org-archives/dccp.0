From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 16 Dec 2008 22:25:59 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081216222559.GR14518@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Dec 16, 2008 at 01:32:00PM -0800, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Tue, 16 Dec 2008 09:19:08 -0200
> 
> > I guess that looking at tcp_set_congestion_control() could be a good
> > start. 8-)
> 
> Certainly.
> 
> But it seems to me we are dealing with a different situation here
> in DCCP.
> 
> On the TCP side we have:
> 
> 1) A default congestion control module, already loaded and
>    which has been selected by the admin via a sysctl setting.

Which we should have in DCCP too, its even in the RFC that CCID2 should
be always available, making a good choice for a default one.
 
> 2) A socket option facility to select a non-default congestion
>    control algorithm to use.

This is the same for DCCP, i.e. the app can tell the ones it wants via
setsockopt, and if the default is all they want, no need to ask for
something to be loaded, i.e. ccid2 (or the one that we think should be
the default, like reno -> BIC -> CUBIC) should be always available.
 
> These are both outside of the fast path.
> 
> Whereas the DCCP case is right in the connection creation fast path
> and unconditionally executes, because it is trying to figure out what
> CCID algorithms it can advertise.

Well, there must be some way to locklessly advertise what was previously
loaded (and thus can't ever be unloaded).

- Arnaldo
