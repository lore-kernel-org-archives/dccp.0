From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 15 Nov 2006 21:27:35 +0000
Subject: Re: CCID3: dead code in ccid3_hc_rx_packet_recv?
Message-Id: <5640c7e00611151327o260f4f52n87052693ee41c224@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611150714q5a87fafbld0425ddb4181f28a@mail.gmail.com>
In-Reply-To: <39e6f6c70611150714q5a87fafbld0425ddb4181f28a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/16/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> While working on the promised EWMA patch for CCID 3 packet sizes, I stumbled over two things
> and can make no sense of a bit of CCID 3 Receive code:
>
>         1) ccid3_hc_rx_sock maintains a real-timer RTT counter ccid3hcrx_rtt
>            which is an alias for a TFRC structure defined in <linux/tfrc.h>

See comments below. Don't really understand what you are saying.

>         2) ccid3_hc_rx_packet_recv (detailed below) updates this, but leaves the variable
>            `win_count = packet->dccphrx_ccval;'  entirely untouched after initialisation
>
This can be deleted. It was used but I have shifted the code into
ccid3_hc_rx_detect_loss. I forgot to delete this variable. I will
produce a patch to do this in next week if you don't.
>                 /*
>                    after updating r_sample with regard to t_elapsed ...
>                    => The code that now follows is identical with ccid3_hc_tx_packet_recv
>                        --is this a leftover ?
>                        --should it not rather update the sending structure (ccid3hctx_rtt)

No they are half connections. Maybe I don't understand your question.
>                    => why not use win_count ??

Can be deleted.
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
