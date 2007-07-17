From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 17 Jul 2007 04:25:50 +0000
Subject: Re: TFRC Faster Restart implementation for Linux DCCP
Message-Id: <5640c7e00707162125h13054951y58d08dee181e2e74@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
In-Reply-To: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

My aim for this is to eventually hit mainline.

I agree that the spec has changed quite significantly and may yet
change again. However I'm in need of more data for my thesis and both
Richard (my supervisor) and Gorry have suggested I look at faster
restart for my ideas. We (Lulea/Wand/Arnaldo) did the initial
implementation of DCCP while the spec was changing so it is kind of
familiar.

I want to be able to keep the code in one tree and there is plenty of
examples of non-RFC compliant code in the Linux kernel for
experimental protocols (e.g. DCCP, SCTP) while they stabilise and
shortly afterwards. My idea is that you can choose whether to use TFRC
faster restart or not. Given how TCP handle extensions I think the
best way for this is a sysctl as can turn it on or off system wide.
The default, initially, should be off. The other alternative is to
enable it via a socket option as TCP Nagle does.

I will be using your git-tree as my development base and once I get it
coded I'd be greatly pleased if you can put it in the tree somehow.

Any comments gratefully received.

Ian

On 7/17/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> You didn't write whether you intend this as Linux mainline work.
>
> I am not aware of anyone else working on this so far. However, it reopens a big can
> of worms for the CCID3 code in the kernel: much in Faster Restart depends on the
> rfc3448bis changes to computing the sending rate and determining idle/application-limited
> times.
> The algorithm keeps changing in each new revision of the rfc3448bis draft, which probably
> means that when you've just finished your work, you can start from scratch again.
>
> Thus my suggestion is - if you want to do this community-wise - to do this as part/sub-branch
> of the testing tree. There is still a lot of space for further branches, and it is not clear
> when all this will stabilise.
>
> Thoughts?
>
> Quoting Ian McDonald:
> |  Folks,
> |
> |  At the suggestion of my PhD supervisor, I am considering implementing
> |  TFRC faster restart for the Linux version of DCCP.
> |
> |  From my reading of the correspondence it would seem to me that the
> |  testing was done in ns2 and not in the Linux kernel. If this is not
> |  correct, or you know of any implementations, can you tell me so I
> |  don't reinvent the wheel!
> |
> |  Thanks,
> |
> |  Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
