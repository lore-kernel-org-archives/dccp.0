From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 16 Dec 2008 11:19:08 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081216111908.GI14518@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Dec 16, 2008 at 01:40:45AM -0800, David Miller escreveu:
> From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Date: Tue, 16 Dec 2008 06:29:54 +0100
> 
> > | Hence I think we have a chance by going completely lockless here, by
> > | loading all configured CCIDs at runtime. In this manner the per-connection
> > | check "are all advertised CCIDs are loaded?" falls under the table, we
> > | do not need to worry about concurrent access, and loading DCCP implies that
> > | all needed CCIDs are there.
> > Unfortunately this won't work since the CCIDs depend on dccp.ko being
> > fully loaded, so requiring that CCID module are loaded during the
> > loading process of dccp.ko creates a cyclic dependency.
> 
> I don't like this stuff at all.
> 
> Every new connection you're going to loop over the CCID
> table and grab that CCID read lock N times.
> 
> The first time it will do something meaningful, and then
> %99.999999999999 of subsequent calls will do nothing.
> 
> What kind of overhead is deserved by that access pattern?
> 
> And, if the first thing the first connection is going to do
> is load all the modules, there is ZERO reason to make them
> modular.  It's just useless seperation and it adds all of
> this rediculious synchronization.
> 
> If it's modular "for the sake of development" I'm sure you
> can simply reload the dccp.ko module when you make some
> CCID algorithm change.
> 
> I'm tossing this patch set until we get something better
> in this area.

I guess that looking at tcp_set_congestion_control() could be a good
start. 8-)

- Arnaldo
