From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Dec 2007 23:53:53 +0000
Subject: Re: mirror?
Message-Id: <20071226235353.GA16076@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200712241443.33716.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200712241443.33716.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Dec 25, 2007 at 08:23:05AM +1300, Ian McDonald escreveu:
> On 12/25/07, Tomasz Grobelny <tomasz@grobelny.oswiecenia.net> wrote:
> > As http://www.erg.abdn.ac.uk/ seems to be down at least since yesterday I'd
> > like to ask whether any mirror of dccp git tree and/or dccp patches to
> > mainline kernel is available. TIA,
> > --
> > Regards,
> > Tomasz Grobelny
> 
> Here is the announcement of the outage:
> 
> Both the dccp and the ccid4 trees have been brought up-to-date and uploaded.
> 
> Due to necessary building work, we have to power down almost all servers in
> the department from
> 
>        Friday  21st December 2007    until
>        Sunday   6th January  2008

I have a clone and just made the whole series available as a single
patch at:

http://oops.ghostprotocols.net:81/acme/dccp/gerrit-2.6/gerrit-pending-review.patch.bz2

The broken out patch series is also at:

http://oops.ghostprotocols.net:81/acme/dccp/gerrit-2.6/

You have to clone from DaveM's net-2.6.25 and then apply the series, for
your convenience:

git clone git://.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25
cd net-2.6.25
wget http://oops.ghostprotocols.net:81/acme/dccp/gerrit-2.6/gerrit-pending-review.patch.bz2
bzcat gerrit-pending-review.patch.bz2 | patch -p1

I plan to review the feature negotiation patch series that is the bulk
of what I still haven't reviewed in Gerrit's pending tree while its
still 2007.

Regards,

- Arnaldo
