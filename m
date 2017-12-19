From: Masami Hiramatsu <mhiramat@kernel.org>
Date: Tue, 19 Dec 2017 01:31:38 +0000
Subject: Re: [v2 PATCH -tip 3/6] net: sctp: Add SCTP ACK tracking trace event
Message-Id: <20171219103138.f3076f81e14f0837c4b2386d@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <151358473510.28850.10475072993963389604.stgit@devbox>
In-Reply-To: <151358473510.28850.10475072993963389604.stgit@devbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, 18 Dec 2017 12:05:16 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> On Mon, 18 Dec 2017 17:12:15 +0900
> Masami Hiramatsu <mhiramat@kernel.org> wrote:
> 
> > Add SCTP ACK tracking trace event to trace the changes of SCTP
> > association state in response to incoming packets.
> > It is used for debugging SCTP congestion control algorithms,
> > and will replace sctp_probe module.
> > 
> > Note that this event a bit tricky. Since this consists of 2
> > events (sctp_probe and sctp_probe_path) so you have to enable
> > both events as below.
> > 
> >   # cd /sys/kernel/debug/tracing
> >   # echo 1 > events/sctp/sctp_probe/enable
> >   # echo 1 > events/sctp/sctp_probe_path/enable
> > 
> > Or, you can enable all the events under sctp.
> > 
> >   # echo 1 > events/sctp/enable
> > 
> > Since sctp_probe_path event is always invoked from sctp_probe
> > event, you can not see any output if you only enable
> > sctp_probe_path.
> 
> I have to ask, why did you do it this way?
> 
> 
> > +#include <trace/define_trace.h>
> > diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
> > index 8f8ccded13e4..c5f92b2cc5c3 100644
> > --- a/net/sctp/sm_statefuns.c
> > +++ b/net/sctp/sm_statefuns.c
> > @@ -59,6 +59,9 @@
> >  #include <net/sctp/sm.h>
> >  #include <net/sctp/structs.h>
> >  
> > +#define CREATE_TRACE_POINTS
> > +#include <trace/events/sctp.h>
> > +
> >  static struct sctp_packet *sctp_abort_pkt_new(
> >  					struct net *net,
> >  					const struct sctp_endpoint *ep,
> > @@ -3219,6 +3222,8 @@ enum sctp_disposition sctp_sf_eat_sack_6_2(struct net *net,
> >  	struct sctp_sackhdr *sackh;
> >  	__u32 ctsn;
> >  
> > +	trace_sctp_probe(ep, asoc, chunk);
> 
> What about doing this right after this probe:
> 
> 	if (trace_sctp_probe_path_enabled()) {
> 		struct sctp_transport *sp;
> 
> 		list_for_each_entry(sp, &asoc->peer.transpor_addr_list,
> 				    transports) {
> 			trace_sctp_probe_path(sp, asoc);
> 		}
> 	}
> 
> The "trace_sctp_probe_path_enabled()" is a static branch, which means
> it's a nop just like a tracepoint is, and will not add any overhead if
> the trace_sctp_probe_path is not enabled.

That's a good idea! I'll update to use it :)

Thank you,

> 
> -- Steve
> 
> > +
> >  	if (!sctp_vtag_verify(chunk, asoc))
> >  		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
> >  
> 


-- 
Masami Hiramatsu <mhiramat@kernel.org>
