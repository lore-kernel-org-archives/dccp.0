From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Thu, 16 Nov 2006 01:24:46 +0000
Subject: Re: [RFC-RESEND] [PATCH]: use explicit enums for CCID 3 states
Message-Id: <39e6f6c70611151724t2f988d56leac123be9f2e827b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611151859.19282@strip-the-willow>
In-Reply-To: <200611151859.19282@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Hi Arnaldo,
>
> thank you for the link @-)
>
> |  > The following is the revised patch with three macros added, I liked the
> |  > DCCP_BUG_ON():
> |
> |  will look into that barring social life that is taking me so much time
> |  that I should be working on DCCP :-P :-) Well, at least its not "Real
> |  Work (tm)" :-)
> I really hope you can get some quality time - there should be funding for all the
> good work you are putting into this.

Thanks, Mandriva allows me to work part time on what I think is
important, barring when there is some important customer project, that
was the case for at least 6 months this year, when I mostly
disappeared from my kernel projects.

> I have made a terrible mess of the previous patch (with the warn semantics,
> it would not have worked correctly). I have tested it and below is what I
> had intended, but was too tired to get clear.

:-)

Seems ok now:

[acme@newtoy net-2.6.20]$ codiff --verbose /tmp/ccid3.o.before /tmp/ccid3.o.enum
/pub/scm/linux/kernel/git/acme/net-2.6.20/net/dccp/ccids/ccid3.c:
  struct ccid3_hc_tx_sock       |   +0
    ccid3hctx_state;
     from: u8                    /*    30(0)     1(0) */
     to:   enum ccid3_hc_tx_states /*    28(8)     4(8) */
  struct ccid3_hc_rx_sock       |   +0
    ccid3hcrx_state:8;
     from: u64                   /*    16(36)     8(8) */
     to:   enum ccid3_hc_rx_states /*    16(0)     4(8) */
    ccid3hcrx_ccval_last_counter:4;
     from: u64                   /*    16(32)     8(4) */
     to:   u64                   /*    16(40)     8(4) */
 2 structs changed
  ccid3_hc_rx_set_state         |  -28
  ccid3_hc_rx_send_feedback     |  +26
  ccid3_hc_rx_init              |  -11
  ccid3_hc_tx_no_feedback_timer |  +32
  ccid3_hc_tx_packet_recv       |  +32
  ccid3_hc_rx_packet_recv       |  -16
  ccid3_hc_rx_get_info          |   -4
  ccid3_hc_tx_send_packet       |  +27
  ccid3_hc_tx_packet_sent       |  +32
 9 functions changed, 149 bytes added, 59 bytes removed

Thanks, applied.

- Arnaldo
