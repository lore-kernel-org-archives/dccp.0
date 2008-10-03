From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 03 Oct 2008 14:18:42 +0000
Subject: Re: Protocol not attached
Message-Id: <20081003141842.GA11242@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Forwarded to leandro/mailing list.

Em Fri, Oct 03, 2008 at 03:01:18PM +0100, gerrit@erg.abdn.ac.uk escreveu:
> >> # modprobe -l
> >> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/ccids/dccp_ccid2.ko
> >> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/ccids/dccp_ccid3.ko
> 
> <snip>
> 
> >> The module did not start in the boot (expected!). I then ran
> >>
> <snip>
> 
> > Go ahead and load it manually, to check if the problem goes away when
> > dccp_ccid2 is loaded.
> >
> > If it is, its narrowed down to the autoloading of CCID modules.
> >
> Yes can you please confirm if that is the case.
> 
> I wonder if this can be influenced by a configuration setting. I tried
> the same, with -rc7 and -rc8, on a Sempron 3700 64 bit and a Dual Core,
> worked without problem.

- Arnaldo
