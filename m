From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 04 Dec 2006 21:14:52 +0000
Subject: Re: [PATCH] DCCP: handle EAGAIN case
Message-Id: <5640c7e00612041314g3a1104dnd0b18575cb378341@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612031538.27300@strip-the-willow>
In-Reply-To: <200612031538.27300@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/5/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:
> |  > a) You helped to uncover at least one real bug here:
> |  >
> |  > long delay;
> |  >
> |  > delay = msecs_to_jiffies(rc);
> |  > if (delay > *timeo || delay < 0)
> |  >
> |
> |  I was thinking of changing the type from long to unsigned long to
> |  match and removing the test too. I agree totally.
> For this case I have prepared a patch. With regard to the EAGAIN case I was
> half waiting for Arnaldo to say something, for the moment I have put it here:
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/experimental_patches/15a_handle_EAGAIN.diff
>
> I think we should fix the EAGAIN case. Maybe also something for EINTR (err=-4).
>
I was thinking about this some more on the way up to work as I biked...

We will only really have a problem with EAGAIN staying in the loop if
we have unbounded tx queues and low x. However I don't think that will
normally be the case as that has to be explicity set via sysctl now.

We do need to be careful with changing the type of delay. We should
change the type of timeo as well to avoid signed/unsigned issues but
then we have the comparison...

And then as I write this  realise we are being way too complicated. We
should remove timeo altogether!!! As we are doing this in effect by
that continue and that is perfectly valid is this is blocking I/O. So
we remove timeo, remove DCCP_XMIT_TIMEO and simplify it a fair bit.

Still thinking about why we are getting EAGAIN and suspect it is due
to you not having that patch but I'll probably add more debugging in.

Anyway feel free to write a patch or I might when I get home from work
or tomorrow.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
