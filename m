From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sat, 08 Dec 2007 18:47:11 +0000
Subject: Re: [PATCH 5/8] [TFRC]: Loss interval code needs the
Message-Id: <20071208184711.GF3180@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11971083883727-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11971083883727-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Dec 08, 2007 at 10:06:25AM +0000, Gerrit Renker escreveu:
> This moves the inlines (which were previously declared as macros) back into packet_history.h since
> the loss detection code needs to be able to read entries from the RX history in order to create the
> relevant loss entries: it needs at least tfrc_rx_hist_loss_prev() and tfrc_rx_hist_last_rcv(), which
> in turn require the definition of the other inlines (macros).
> 
> Additionally, inn one case the use of inlines instead of a macro broke the algorithm: rx_hist_swap()
> (introduced in next patch) needs to be able to swap the history entries; when using an inline returning
> a pointer instead, one gets compilation errors such as:
> 
>   distcc[24516] ERROR: compile /root/.ccache/packet_his.tmp.aspire.home.net.24512.i on _tiptop failed
>   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c: In function '__one_after_loss':
>   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:266: error: lvalue required as unary '&' operand
>   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:267: error: lvalue required as unary '&' operand
>   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c: In function '__two_after_loss':
>   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:298: error: lvalue required as unary '&' operand
>   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:299: error: lvalue required as unary '&' operand
>   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:336: error: lvalue required as unary '&' operand
>   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:337: error: lvalue required as unary '&' operand
>   make[4]: *** [net/dccp/ccids/lib/packet_history.o] Error 1
>   make[3]: *** [net/dccp/ccids/lib] Error 2
>   make[2]: *** [net/dccp/ccids] Error 2
>   make[1]: *** [net/dccp/] Error 2
>   make: *** [sub-make] Error 2

Because you do it this way:

tfrc_rx_hist_swap(&TFRC_RX_HIST_ENTRY(h, 0), &TFRC_RX_HIST_ENTRY(h, 3));

I checked and at least in this patch series all uses are of this type,
so why not do it using just the indexes, which would be simpler:

tfrc_rx_hist_swap(h, 0, 3);

With this implementation:

static void tfrc_rx_hist_swap(struct tfrc_rx_hist *h, const int a, const int b)
{
	const int idx_a = tfrc_rx_hist_index(h, a),
	      int idx_b = tfrc_rx_hist_index(h, b);
	struct tfrc_rx_hist_entry *tmp = h->ring[idx_a];

	h->ring[idx_a] = h->ring[idx_b];
	h->ring[idx_b] = tmp;
}

- Arnaldo
