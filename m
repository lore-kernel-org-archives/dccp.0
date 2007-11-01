From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Thu, 01 Nov 2007 11:05:07 +0000
Subject: Re: [PATCH 14/25] Basic implementation for ccid-4 dropped packet
Message-Id: <20071101110507.GC4928@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200710312131.40317.leandroal@gmail.com>
In-Reply-To: <200710312131.40317.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Oct 31, 2007 at 09:31:40PM -0300, Leandro escreveu:
> [CCID-4] Basic implementation for ccid-4 dropped packet option as per ccid-4 draft
> 
> Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
> 
> Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
> =================================> --- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
> +++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
> @@ -36,12 +36,15 @@ enum tfrc_options {
>  	TFRC_OPT_LOSS_EVENT_RATE = 192,
>  	TFRC_OPT_LOSS_INTERVALS	 = 193,
>  	TFRC_OPT_RECEIVE_RATE	 = 194,
> +	TFRC_OPT_DROPPED_PACKETS = 195, /* as per ccid-4 draft, section 8 */
>  };
>  
>  struct tfrc_options_received {
>  	u64 tfrcor_seqno:48,
> -	    tfrcor_loss_intervals_idx:16;
> -	u16 tfrcor_loss_intervals_len;
> +	    tfrcor_loss_intervals_idx:16,
> +	    tfrcor_dropped_packets_idx:16;

Just make tfrcor_dropped_packets_idx a plain u16.
tfrcor_loss_intervals_idx is part of a bitfield together with
tfrcor_seqno because it is 48 bits and we want to use what is left in a
u64.

Making tfrcor_dropped_packets_idx a 16 bits entry in a 16 bits bitfield
doesn't helps us here and likely produces bad code.


> +	u16 tfrcor_loss_intervals_len,
> +            tfrcor_dropped_packets_len;
>  	u32 tfrcor_loss_event_rate;
>  	u32 tfrcor_receive_rate;
>  };

And even leads to some confusion, one would think that the second,
single entry bitfield would use 64 bits, as it is declared u64, but the
rule is:

[acme@doppio ~]$ pahole bitfield
struct tfrc_options_received {
        u64  tfrcor_seqno:48;               /*   0 8 */
        u64  tfrcor_loss_intervals_idx:16;  /*   0 8 */
        u64  tfrcor_dropped_packets_idx:16; /*   8 8 */

        /* Bitfield WARNING: DWARF size=8, real size=2 */

        u16  tfrcor_loss_intervals_len;     /*  10 2 */
        u16  tfrcor_dropped_packets_len;    /*  12 2 */

        /* XXX 2 bytes hole, try to pack */

        u32  tfrcor_loss_event_rate;        /*  16 4 */
        u32  tfrcor_receive_rate;           /*  20 4 */

        /* size: 24, cachelines: 1 */
        /* sum members: 22, holes: 1, sum holes: 2 */
        /* last cacheline: 24 bytes */
};      /* definitions: 1 */

[acme@doppio ~]$

The rule is so confusing that even gcc gets lost and emits debugging
information where it says the type of the bitfield is u64, thus 8 bytes
wide, but the offset of the next field is 2 bytes after the bitfield :-)

So just make it u16 and we'll get this:

[acme@doppio ~]$ pahole bitfield

[acme@doppio ~]$ pahole bitfield
struct tfrc_options_received {
        u64  tfrcor_seqno:48;		   /*   0 8 */
        u64  tfrcor_loss_intervals_idx:16; /*   0 8 */
        u16  tfrcor_dropped_packets_idx;   /*   8 2 */
        u16  tfrcor_loss_intervals_len;	   /*  10 2 */
        u16  tfrcor_dropped_packets_len;   /*  12 2 */

        /* XXX 2 bytes hole, try to pack */

        u32  tfrcor_loss_event_rate;       /*  16 4 */
        u32  tfrcor_receive_rate;          /*  20 4 */

        /* size: 24, cachelines: 1 */
        /* sum members: 22, holes: 1, sum holes: 2 */
        /* last cacheline: 24 bytes */
};      /* definitions: 1 */

[acme@doppio ~]$

And now we have a 2 bytes hole, so we may as well just stop
making the first two fields a bitfield.

- Arnaldo
