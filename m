From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Wed, 15 Nov 2006 15:14:36 +0000
Subject: Re: CCID3: dead code in ccid3_hc_rx_packet_recv?
Message-Id: <39e6f6c70611150714q5a87fafbld0425ddb4181f28a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> While working on the promised EWMA patch for CCID 3 packet sizes, I stumbled over two things
> and can make no sense of a bit of CCID 3 Receive code:
>
>         1) ccid3_hc_rx_sock maintains a real-timer RTT counter ccid3hcrx_rtt
>            which is an alias for a TFRC structure defined in <linux/tfrc.h>
>         2) ccid3_hc_rx_packet_recv (detailed below) updates this, but leaves the variable
>            `win_count = packet->dccphrx_ccval;'  entirely untouched after initialisation
>
> It may be that ... ?
>         * this is because a real-time counter as opposed to the 4-digit window value
>           counter affords better reliability (but then win_count should be removed)
>         * this stems from the original TFRC code and might need update

Well, the ccid3 codebase has a long lineage, came from Lulea, passed
thru Waikato and the thru my linux CodingStyle and use slab caches,
turn parts into a lib, etc, so it may have all sorts of dragons, oops,
bugs lurking, Ian has more knowledge about CCID3 and the original
Waikato codebase, so he may well answer your questions while I try to
get the rest of the patch queue processed :-)

- Arnaldo
