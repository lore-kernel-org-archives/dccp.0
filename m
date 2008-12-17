From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 17 Dec 2008 13:13:47 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081217131347.GS14518@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Dec 16, 2008 at 03:11:51PM -0800, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@redhat.com>
> Date: Tue, 16 Dec 2008 20:25:59 -0200
> 
> > Em Tue, Dec 16, 2008 at 01:32:00PM -0800, David Miller escreveu:
> > > From: Arnaldo Carvalho de Melo <acme@redhat.com>
> > > Date: Tue, 16 Dec 2008 09:19:08 -0200
> > > 
> > > Whereas the DCCP case is right in the connection creation fast path
> > > and unconditionally executes, because it is trying to figure out what
> > > CCID algorithms it can advertise.
> > 
> > Well, there must be some way to locklessly advertise what was previously
> > loaded (and thus can't ever be unloaded).
> 
> This gets us back to my original objection.
> 
> Can these things be unloaded?  If not, and they get unconditionally
> all loaded up on the first DCCP connection, why make them seperate
> modules at all?
> 
> If they can get unloaded, then you need synchronization.
> 
> I would recommend that everything gets built into dccp.ko
> and thus the table is fixed and never changes and thus no
> locking nor any of this funny mod loading is needed at all.

Perhaps we can have something like we have with the tcp congestion
modules: the modules that are non experimental, because they are already
in an RFC and/or the implementation was deemed stable, should be linked
with dccp.ko and would by default be advertised, i.e. they are the system
wide available CCIDs as configured at kernel build time.

But then, if the user, after he creates the socket, on the slow path,
does a setsockopt asking for a newer CCID (CCID4 is in the works, for
instance) to be advertised for this specific connection or if it asks
for some in the static set of CCIDs _not_ to be advertised, then the
feature negotiation code will advertise the selected set.

Only applications wanting newer stuff will incur the cost of the synch
at connection time while the majority will not incur such costs by
using the penguin peed static CCIDs.

I.e. a VOIP app would say that it is not interested in CCID2, wanting
only CCID3 or CCID4.

IOW we're back to my suggestion on looking at
tcp_set_congestion_control(). :-)

- Arnaldo
