From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 01 Jan 2008 19:04:55 +0000
Subject: Re: panic on 2.6.24rc5
Message-Id: <20080101190455.GA25000@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200712280016.56674.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Em Sun, Dec 30, 2007 at 04:18:36PM +0100, Tomasz Grobelny escreveu:
> On Friday 28 December 2007, I wrote:
> > Dnia Wednesday 26 of December 2007, napisałeś:
> > > What are the panics you are getting? It might be worth posting them to
> > > the list.
> >
> > Here is the screenshot I captured a few days ago. Details:
> >  - kernel-vanilla 2.6.24rc5,
> Now I'm using kernel as described in Arnaldo's mail (davem/net-2.6.25 + 
> patches 0001 to 0051).

dccp_hdlr_ack_ratio is not on net-2.6.25, which means it is in one of
the 0001 to 0051 patches from Gerrit. So, to help us understand where is
the problem you could try building a kernel without applying any of the
0001 to 0051 patches.

Could you do this at and report the results?

I'm also assuming you are using CCID2 either by explicitely using
feature negotiation setsockopt calls or by using the default, that is
CCID2. If this is the case it would also be interesting to, before
rebuilding the kernel, to try using CCID3 as the problem you're
experiencing when using netem is exactly in the interface between the
core DCCP code and the CCID being used.

- Arnaldo
