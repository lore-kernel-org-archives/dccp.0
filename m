From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 22 Nov 2006 18:06:12 +0000
Subject: Re: [PATCH 3/6]: Fix calculation of t_ipi time of scheduled transmission
Message-Id: <5640c7e00611221006n6a0e4ca0j905a8816a8139675@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
In-Reply-To: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/23/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:
> |  I'll have to have a think about this one some more as I spent a lot of
> |  time fixing these timing and I distinctly remember getting this one
> |  right!
> Please relax: It is not my intention to embark on a game of "who is right here". I think
> you have done a good job getting this code so far as it is, given the many and in parts
> confusing documents that have to be read (for comparison: UDP, RFC 768, needs only 3 pages).
> My intention is in making sure it meets the specifications and contribute where I can to fix things.

Gerrit - I was not trying to cast dispersions on you at all. I just
wanted some time to review it properly as I've spent a bit of time in
this code and would like to review CCID3 changes before they merge.

As it turns out I was wrong in my calculation here. I fixed up the
calculation of packet sending times which used to be wrong but I got
this part (delta) wrong by reversing signs.

>   => Since these bits are so similar, I would actually suggest to accommodate them in
>       one function, since:
>                 --t_ipi changes only if one of `s' or X_calc changes
>                 --if `s' / X_calc remain unchanged after feedback, t_ipi remains as before
>                 --t_delta depends on t_ipi
>                 --the calculation of t_nom depends on t_ipi (as in the above snippets)
>

Agree.

Gerrit - I really appreciate the work you are doing on CCID3. I'm
pretty sure you're a better programmer than me, I just get a little
sensitive with CCID3 being "my baby" for a fair bit.

Onwards and upwards.

Regards,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
