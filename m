From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 28 May 2008 14:17:03 +0000
Subject: Re: Monitoring DCCP: modprobe dccp_probe
Message-Id: <20080528141703.GF30251@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <483D424F.5020307@libero.it>
In-Reply-To: <483D424F.5020307@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, May 28, 2008 at 09:50:10AM -0300, Leandro Sales escreveu:
> On Wed, May 28, 2008 at 9:38 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > Quoting Giuseppe Galeota:
> >> Under General Setup I haven't found Kprobes, but I found Kprobes inside Instrumentation Support, and it is already active.
> >> About DCCP I can see only:
> >> Networking->Networking support->THE DCCP protocol->DCCP CCIDs
> >> configurations-->CCID2/3 debugging messages, that are already active,
> >> while I haven't found 'DCCP connection probing'.
> >>
> > This means that the dependency for dccp_probe is not satisfied.
> > The only other dependency of dccp_probe is CONFIG_PROC_FS, but this is
> > not normally off. Maybe if you are using non-x86 hardware there is a
> > problem with kprobes?
> 
> Yes, this should be the point. For instance, I'm maintaining DCCP
> source code for maemo platform (ARM) that runs with 2.6.21 kernel
> version and they do not provide KProbes and for this case I had to
> make some internal changes to avoid dccp kprobes. As Gerrit said,
> check if kprobe dependencies are selected.

Since kprobes is not available everywhere and dccp_probe (and tcp_probe
for that matter) only hook into ->sendmsg, what about adding a:

	DCCP_PROBE(sk);

in dccp_sendmsg and make it dependent on CONFIG_DCCP_PROBE, make it
check a sysctl_dccp_probe_enabled (/proc/sys/net/dccp/probe_enabled) and
if so, call the routine that is now installed via a jprobe.

With a bit more logic one could make this be a no-op on architectures
where kprobes is available and use the above idea when kprobes is not
present, be it because the arch doesn't have support for it or because
one don't want to have kprobes built-in to for some reason.

Leandro probably could do it quickly since he already seems to be using
such a scheme, no?

- Arnaldo
