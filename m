From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 15 Nov 2006 17:28:04 +0000
Subject: Re: CCID3: dead code in ccid3_hc_rx_packet_recv?
Message-Id: <5640c7e00611150928m2efc13cbnd8936908704cd488@mail.gmail.com>
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
>         2) ccid3_hc_rx_packet_recv (detailed below) updates this, but leaves the variable
>            `win_count = packet->dccphrx_ccval;'  entirely untouched after initialisation
>
> It may be that ... ?
>         * this is because a real-time counter as opposed to the 4-digit window value
>           counter affords better reliability (but then win_count should be removed)
>         * this stems from the original TFRC code and might need update
>
I'll have a look at it when I get the chance. I know the win_count
code in CCID3 is screwed at the moment and I just hacked it by
removing some lines as it was making loss intervals wrong which made
performance wrong.

It does need fixing properly though and there are large parts of code
that don't do anything but should be fixed up to meet RFC. I haven't
removed some of it though so I know what it was...

Anyway I'll have a look at it as I can but feel free to make patches.
If you're removing chunks of code I'd prefer it commented out in the
meantime rather than removed.

Ian

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
