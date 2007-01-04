From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 04 Jan 2007 21:57:58 +0000
Subject: Re: [PATCH 1/5]: DCCP Fix use of invalid loss intervals
Message-Id: <5640c7e00701041357q3ae4f98ake2ff4e55b6a4bbda@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201544.22122.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201544.22122.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/5/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> Ian (catching up slowly slowly), here is a nit as nitty as they come.
>
> This diff seems strange to me, since ~ actually does the same thing on
> integers and unsigned integers.  (This code:
>
>      printf("%u %u\n", ~0, ~0U);
>
> will print the same thing twice.)
>
> Perhaps dccplih_interval is a 64-bit number?  In which case you want to
> say something like ~0ULL?
>
> Eddie

Printing gives them the same result as you are using a %u mask. If you
do it with a %d mask you will get a different result.

And that is the issue dccp_lih_interval is unsigned 32 bit and ~0 is a
signed number and is large negative and they therefore can't be equal.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
