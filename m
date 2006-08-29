From: Burak Gorkemli <burakgmail-dccp@yahoo.com>
Date: Tue, 29 Aug 2006 01:03:15 +0000
Subject: Re: low tx speed in ccid3 after loss
Message-Id: <20060829010315.68422.qmail@web30006.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
References: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
In-Reply-To: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian,

I am reading the ccid3 code for a while now and it seems to me that "the interval since the most recent packet loss event" is not taken into account while calculating I_mean, as you and Edgar suspect.  The first interval used for calculating i_tot0 in dccp_li_hist_calc_i_mean() should point to "the interval since the most recent packet loss event", but it does not, I guess. In the morning I will debug this more and try to fix it, if all goes well. Actually I did some modifications today but they did not relieve my problems altogether.

BTW, can you recommend me a tool for debugging the ccid (and dccp) module? I think there is Ostra but you seem to discourage its usage in the Ostra wiki page (http://wiki.linux.net.nz/Ostra). 

--
Burak Gorkemli
Ph.D. Candidate
Koc University
Turkey


----- Original Message ----
From: Ian McDonald <ian.mcdonald@jandi.co.nz>
To: Edgar E. Iglesias <edgar.iglesias@axis.com>
Cc: Burak Gorkemli <burakgmail-dccp@yahoo.com>; dccp@vger.kernel.org; DCCP mailing list <dccp@ietf.org>
Sent: Tuesday, August 29, 2006 2:38:09 AM
Subject: Re: low tx speed in ccid3 after loss

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



