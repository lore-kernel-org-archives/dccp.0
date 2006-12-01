From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 01 Dec 2006 18:26:31 +0000
Subject: Re: [BUG] CCID3 performance is f**ked
Message-Id: <5640c7e00612011026k95a0a15qe1ee27bb51d177eb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
In-Reply-To: <5640c7e00611301425v1c0c4b07kfeace18480cd0039@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Thank you for this carefully worded bug report :-)
>
> Really, with the number of bugs that are still in the code, I am actually
> amazed that we get this far 8-)
>
> I don't think that doing performance-testing at this stage is of any use.
> When you repair your car and take out half of the engine, then take it
> for a spin, do you expect top-gear performance?

I don't really have time to respond properly at present. However I
would say we shouldn't ever be making kernel worse and basically not
working. My standard for submitting patches is that it still works at
least as well as before. It's not good when users pull kernels and
they don't work. It takes me (and anybody else) five minutes to test
after each set of patches that I do. However it takes me hours/day to
bisect faulty kernel trees.

> Thank you for forwarding this onto the IETF list.

I am not sure if this is sarcasm or not. By forwarding to the IETF
list I was trying to resolve a protocol (not implementation) issue of
timers going off all the time - which unfortunately hasn't been
answered yet. You're solving the problem in a good way but I wanted
DCCP fixed (not your code). I'm sorry if I offended you - it wasn't my
intent.

-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
