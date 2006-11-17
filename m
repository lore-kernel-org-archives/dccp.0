From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 17 Nov 2006 01:41:09 +0000
Subject: Re: [RFC PATCH 1/2]: DCCP Introduce tx queue limits
Message-Id: <5640c7e00611161741o5ca8d93fv1bbaec29a60534e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611161037.32393.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200611161037.32393.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> This is great to have! Indeed, it is very useful - without control on the tx buffer, it can
> lead to much increased jitter (if too much gets blocked). Ideally, this could be a socket option
> but I don't think that it is necessary now. It would be good to have this submitted. I had meant
> to update it with regard to the latest change sets, but my connection is sluggish and I also need
> to update the patch backlog.
> If you submit this, I can take care of making it applicable to the latest changes.

Yes I agree it would be good to have as a socket option and will look
at that sometime (maybe not soon).

I tried to get my git trees up to date but kernel.org stuff is
basically unusable at present.

If you want to then you can update otherwise I will try again after
the weekend (going to see WRC stage shortly and birthday tomorrow).
>
> Please see inline.

Think I got these all. Will resend patches shortly.

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
