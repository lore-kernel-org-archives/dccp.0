From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Wed, 15 Nov 2006 15:10:50 +0000
Subject: Re: [RFC] [PATCH]: use explicit enums for CCID 3 states
Message-Id: <39e6f6c70611150710g23ad053dp91a46bde964e7187@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611151401.41404@strip-the-willow>
In-Reply-To: <200611151401.41404@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This patch tackles the following problem:
>         * the ccid3_hc_{t,r}x_sock define ccid3hc{t,r}x_state as `u8', but
>           in reality there can only be a few, pre-defined enum names
>         * this necessitates addiditional checking for unexpected values
>           which would otherwise be caught by the compiler

My problem is with the changes to the structs, from u8 to enums, that
take 4 bytes, <shameless plug>see using my new tool, codiff (code
diff):

[acme@newtoy net-2.6.20]$ codiff --structs --verbose
/tmp/ccid3.o.before /tmp/ccid3.o.enum
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/dccp/ccids/ccid3.c:
  struct ccid3_hc_tx_sock       |   +4
    ccid3hctx_state;
     from: u8                      /*    30(0)     1(0) */
     to:   enum ccid3_hc_tx_states /*    32(0)     4(0) */
  struct ccid3_hc_rx_sock       |   +4
    ccid3hcrx_state:8;
     from: u64                     /*    16(36)    8(8) */
     to:   enum ccid3_hc_rx_states /*    20(0)     4(0) */
 2 structs changed
[acme@newtoy net-2.6.20]$

</shameless plug>

I removed the other parts of the patch (replacing printks+dump_stack
with BUG) to see what would be the code impact of such change and was
surprised:

[acme@newtoy net-2.6.20]$ codiff --functions /tmp/ccid3.o.before
/tmp/ccid3.o.enum
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/dccp/ccids/ccid3.c:
  ccid3_hc_rx_set_state         |  -33
  ccid3_hc_tx_set_state         |   -5
  ccid3_hc_rx_send_feedback     |  -16
  ccid3_hc_rx_init              |   -8
  ccid3_hc_tx_init              |   +3
  ccid3_hc_tx_no_feedback_timer |  -14
  ccid3_hc_rx_packet_recv       |  -48
  ccid3_hc_rx_get_info          |   -5
 8 functions changed, 3 bytes added, 129 bytes removed
[acme@newtoy net-2.6.20]$

Anyway, there are always tradeoffs, compiler gets more info, but we
end up using more memory per socket instance, I guess we can stay like
we are now, no? :-)

- Arnaldo

Probably because we stop using a u64 bitfield in the rx case...
