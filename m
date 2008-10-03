From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 03 Oct 2008 13:24:13 +0000
Subject: Re: Protocol not attached
Message-Id: <20081003132413.GG17843@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Fri, Oct 03, 2008 at 02:44:43AM -0300, Leandro Sales escreveu:
> On Thu, Oct 2, 2008 at 1:47 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > | Then, is it necessary to report this issue in the kernel dev maillist?
> > |
> > Before you do, can you check whether this issue is due to loading
> > modules on request. The DCCP protocol driver will return EUNATCH if it
> > is not able to load the compiled-in CCID modules.
> >
> > The way to test this is: unload all DCCP modules, start application
> > (with or without error), and then see which modules are loaded.
> >
> > If the compiled-in CCIDs have been loaded successfully from within DCCP
> > then the problem is somewhere else.
> >
> 
> Hello Gerrit and others,
>    we compiled 2.6.27-rc4 with DCCP as module in my testbed desktop.
> 
> # modprobe -l
> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/dccp_diag.ko
> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/ccids/lib/dccp_tfrc_lib.ko
> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/ccids/dccp_ccid2.ko
> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/ccids/dccp_ccid3.ko
> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/dccp_ipv6.ko
> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/dccp_ipv4.ko
> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/dccp.ko
> /lib/modules/2.6.27-rc4-44301-g8269be1/kernel/net/dccp/dccp_probe.ko
> 
> The module did not start in the boot (expected!). I then ran
> 
> "strace -f -e trace=network iperf -s -d -l 1424 -i 1"
> 
> and:
> 
> # lsmod
> Module                  Size  Used by
> dccp_tfrc_lib          17868  0
> dccp_ipv6              14916  2
> dccp_ipv4              14596  3 dccp_ipv6
> dccp                   58176  2 dccp_ipv6,dccp_ipv4
> 
> DCCP did not load the dccp_ccid2 module. Is this the problem?
> 
> Just to let you know:
> # cat /proc/sys/net/dccp/default/rx_ccid /proc/sys/net/dccp/default/tx_ccid
> 2
> 2
> 
> I then tested tested with 2.6.27-rc8, the same as with 2.6.27-rc4.
> 
> So, what is your opinion?

Go ahead and load it manually, to check if the problem goes away when
dccp_ccid2 is loaded.

If it is, its narrowed down to the autoloading of CCID modules.

- Arnaldo
