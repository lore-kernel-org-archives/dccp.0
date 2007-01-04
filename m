From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 04 Jan 2007 23:58:37 +0000
Subject: Re: [dccp] Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <5640c7e00701041558l7f487d5j6f7499cbe9d80677@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/5/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> > The reason for this is if you are recalculating i_mean based on non
> > loss you should check after every packet received. However this
> > involves quite a lot of calculations on linked lists which are CPU
> > intensive and also stall other processes potentially with locks being
> > taken. So what I've done is looked at how many packets of non loss
> > would be required to alter i_mean. This is then added to the current
> > sequence number and stored in hist_recalc_recalcloss. I then just do a
> > simple comparison on every packet to see if we've met this high water
> > mark.
>
> I guess there's a minor 4-byte space tradeoff here, but it would seem simpler
> just to store i_tot0 and i_tot1 as variables in the ccid3 structure.  Then on
> every consecutive non-lost packet you simply increment i_tot1 by 4 and
> recalculate i_mean.
>
> Eddie
>
Don't you still need to iterate through each element of the list then
and also do some divisions? This becomes expensive quickly if done for
every packet. With my code for example if you are running at 1% loss
then you will only recalculate roughly every 100 packets and only then
if you haven't had a loss.

I would like to change the loss interval linked list to a fixed size 8
element array as we're not changing the size of the linked list at any
time so it is very inefficient (probably a text book case of when not
to use a linked list!!)

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
