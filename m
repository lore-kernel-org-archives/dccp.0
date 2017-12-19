From: Steven Rostedt <rostedt@goodmis.org>
Date: Tue, 19 Dec 2017 15:20:24 +0000
Subject: Re: [PATCH -tip v3 3/6] net: sctp: Add SCTP ACK tracking trace event
Message-Id: <20171219102024.09a92c75@gandalf.local.home>
List-Id: <dccp.vger.kernel.org>
References: <151367390483.32364.4432870291926458046.stgit@devbox>
In-Reply-To: <151367390483.32364.4432870291926458046.stgit@devbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, 19 Dec 2017 17:58:25 +0900
Masami Hiramatsu <mhiramat@kernel.org> wrote:

> +TRACE_EVENT(sctp_probe,
> +
> +	TP_PROTO(const struct sctp_endpoint *ep,
> +		 const struct sctp_association *asoc,
> +		 struct sctp_chunk *chunk),
> +
> +	TP_ARGS(ep, asoc, chunk),
> +
> +	TP_STRUCT__entry(
> +		__field(__u64, asoc)
> +		__field(__u32, mark)
> +		__field(__u16, bind_port)
> +		__field(__u16, peer_port)
> +		__field(__u32, pathmtu)
> +		__field(__u32, rwnd)
> +		__field(__u16, unack_data)
> +	),
> +
> +	TP_fast_assign(
> +		struct sctp_transport *sp;
> +		struct sk_buff *skb = chunk->skb;
> +
> +		__entry->asoc = (__u64)asoc;
> +		__entry->mark = skb->mark;
> +		__entry->bind_port = ep->base.bind_addr.port;
> +		__entry->peer_port = asoc->peer.port;
> +		__entry->pathmtu = asoc->pathmtu;
> +		__entry->rwnd = asoc->peer.rwnd;
> +		__entry->unack_data = asoc->unack_data;
> +
> +		if (trace_sctp_probe_path_enabled()) {
> +			list_for_each_entry(sp, &asoc->peer.transport_addr_list,
> +					    transports) {
> +				trace_sctp_probe_path(sp, asoc);
> +			}
> +		}

I thought you were going to move this into the code, like I suggested?

-- Steve

> +	),
> +
> +	TP_printk("asoc=%#llx mark=%#x bind_port=%d peer_port=%d pathmtu=%d "
> +		  "rwnd=%u unack_data=%d",
> +		  __entry->asoc, __entry->mark, __entry->bind_port,
> +		  __entry->peer_port, __entry->pathmtu, __entry->rwnd,
> +		  __entry->unack_data)
> +);
> +
