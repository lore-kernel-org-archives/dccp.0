From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 17 Nov 2006 00:33:37 +0000
Subject: Re: [BUG] DCCP performance stops on CCID3 at times
Message-Id: <5640c7e00611161633q19f0e57bm71930db3155ad1b4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611161055.31036.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200611161055.31036.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

Comments inline.

On 11/17/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>It is great to see that this is picked up. It is one of the items
which I had put onto the ToDo >list as well,
>the thread starting this began on
>               http://www.mail-archive.com/dccp%40vger.kernel.org/msg00446.html

That is the same bug as
http://www.mail-archive.com/dccp@vger.kernel.org/msg00467.html which I
mentioned in my original email.

> |  Nov  3 02:27:46 localhost kernel: [44880.646538] tmp2 = 0 ccid3_hc_rx_calc_first_li: x_recv = 0, rtt =1
> I wonder whether this is due to the RTT, due to the following statement in ccid3_hc_rx_calc_first_li:
>         if (rtt = 0)
>                 rtt = 1;

Of course it is! I feel stupid I didn't find that one....

> Maybe it would be good to print out when the RTT estimate is zero (with regard to the other email, I am still
> puzzled about the Receiver-RTT measurement). The same statement re-appears in tfrc_calc_x (to avoid division-by-zero),
> without warning.
> I think that a warning message could bring in some light: maybe it is the case here that the RTT measurement is just
> at rock bottom, always returns 0,  and thus always stays at 1.

It was just put in there to stop divide by zeros. It wasn't meant to
be a proper fix.
>
>
> It would be great if you could come up with something, you know this code best. I have put it into my `TBD' folder
> and may just pester with emails later ;-)

Yes I will try and look at it all again when I get the chance.
>
> There is another thread which I think may be of relevance, incidentally again at the rx_packet_recv function:
>
>         http://www.mail-archive.com/dccp%40vger.kernel.org/msg00118.html
>
This one has already been fixed. If you look at the code it's changed
a fair bit since then. This was a bug which crippled my testing and I
was glad to get sorted. I also removed some of the cc_val/window stuff
at this point as I figured 80% working was better than 0% working as
regards to congestion control...

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
