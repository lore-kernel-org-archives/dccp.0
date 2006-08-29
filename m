From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 29 Aug 2006 01:21:40 +0000
Subject: Re: low tx speed in ccid3 after loss
Message-Id: <5640c7e00608281821y2b70523fu98da7a21cdeb0125@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
In-Reply-To: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/29/06, Burak Gorkemli <burakgmail-dccp@yahoo.com> wrote:
> Hi Ian,

Hi Burak,

Just replying on the dccp list only - ietf don't need to know
implementation details.
>
> I am reading the ccid3 code for a while now and it seems to me that "the interval since the most recent packet loss event" is not taken into account while calculating I_mean, as you and Edgar suspect.  The first interval used for calculating i_tot0 in dccp_li_hist_calc_i_mean() should point to "the interval since the most recent packet loss event", but it does not, I guess. In the morning I will debug this more and try to fix it, if all goes well. Actually I did some modifications today but they did not relieve my problems altogether.

Correct. I am sure of that since I wrote that code - you are running
the latest patches I presume? Basically how I would write the code is
to see if p including the non-loss time is less than p excluding it
then change p.

>
> BTW, can you recommend me a tool for debugging the ccid (and dccp) module? I think there is Ostra but you seem to discourage its usage in the Ostra wiki page (http://wiki.linux.net.nz/Ostra).

Ostra is a great tool but it is a little bit out of date at present as
Arnaldo has been very busy.

I used a mixture of printk's spread around the place and dccp_probe
(which is on my website in the patches).

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
