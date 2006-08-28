From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 28 Aug 2006 23:38:09 +0000
Subject: Re: low tx speed in ccid3 after loss
Message-Id: <5640c7e00608281638h22c837e0p2db40880b07ca776@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
In-Reply-To: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/28/06, Edgar E. Iglesias <edgar.iglesias@axis.com> wrote:
> Hi Ian,
>
> I beleive you need to recompute the loss rate on every received data packet.
> While there is no packet loss, the average loss interval will increase and
> p will decrease.
>
> This is because we take into account the interval between the lastest loss
> event and the current sequence number if it helps us increase the rate.
>
> RFC 3448:
> "When calculating the average loss interval we need to decide whether
>     to include the interval since the most recent packet loss event.  We
>     only do this if it is sufficiently large to increase the average
>     loss interval."
>
> Without this, TFRC will never push the rate up to find newly added bw, unless
> it is in slowstart ofcourse.
>
Thanks for this. I suspected that there would be something like this
but I just didn't see it!

At some stage I might code this up for the Linux implementation but
I'm happy for somebody else to attempt (Burak?) as it's not affecting
me right now.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
