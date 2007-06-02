From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sat, 02 Jun 2007 18:15:21 +0000
Subject: Re: [dccp] Re: problem with CCID3 loss events
Message-Id: <39e6f6c70706021115k7f01dd66pa375ce094074803f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <9442.39900.qm@web30009.mail.mud.yahoo.com>
In-Reply-To: <9442.39900.qm@web30009.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/1/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 6/2/07, Patrick Andrieux <patrick.andrieux@gmail.com> wrote:
> > Hi again,
> >
> > I find out what was the problem. I recompile the latest 2.6.20 kernel
> > with Ian's patches, and my iperf client doesn't freeze anymore. So I
> > guess there is something wrong in Dave Miller's tree (I didn't use
> > Ian's patches).
> > dccp_probe module doesn't work either with his tree, it seg fault
> > trying to insert it.
> >
> > Patrick.
> >
>
> Can you send your kernel .config files and also the scripts you use to
> load dccp and netem so I can try and replicate here and fix.
>
> I can't promise a quick fix but will look into it. Given Dave M's tree
> for DCCP is the same as what Linus has I would like to fix it...
>
> Do you have any more info from the segfault or freeze in your logs?

Please, send all this information to the list.

- Arnaldo
