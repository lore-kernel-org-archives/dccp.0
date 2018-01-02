From: Julia Lawall <julia.lawall@lip6.fr>
Date: Tue, 02 Jan 2018 15:16:30 +0000
Subject: Re: [Cluster-devel] [PATCH 00/12] drop unneeded newline
Message-Id: <alpine.DEB.2.20.1801021615510.23552@hadrien>
List-Id: <dccp.vger.kernel.org>
References: <1878806802.2632123.1514901158666.JavaMail.zimbra@redhat.com>
In-Reply-To: <1878806802.2632123.1514901158666.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On Tue, 2 Jan 2018, Bart Van Assche wrote:

> On Tue, 2018-01-02 at 15:00 +0100, Julia Lawall wrote:
> > On Tue, 2 Jan 2018, Bob Peterson wrote:
> > > ----- Original Message -----
> > > > ----- Original Message -----
> > > >
> > > Still, the GFS2 and DLM code has a plethora of broken-up printk messages,
> > > and I don't like the thought of re-combining them all.
> >
> > Actually, the point of the patch was to remove the unnecessary \n at the
> > end of the string, because log_print will add another one.  If you prefer
> > to keep the string broken up, I can resend the patch in that form, but
> > without the unnecessary \n.
>
> Please combine any user-visible strings into a single line for which the
> unneeded newline is dropped since these strings are modified anyway by
> your patch.

That is what the submitted patch (2/12 specifically) did.

julia
