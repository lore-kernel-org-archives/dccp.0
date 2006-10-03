From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 03 Oct 2006 18:26:27 +0000
Subject: Re: PACKET_SIZE option and congestion control on variable-length packets
Message-Id: <5640c7e00610031126n7a13c8b0ib3fc7c12c6912363@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200610021108.57676@strip-the-willow>
In-Reply-To: <200610021108.57676@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/3/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  > Strategy
> |  > ----------
> |  > 1/ Remove the PACKET_SIZE socket options as they don't help with the problem;
> |  >     I have therefore updated Ian's patch to be used standalone [attached].
> |
> |  NAK this patch. At present it just sets s to be 256 bytes where the
> |  spec says to use the MSS. My patch is not perfect but it is better
> |  than this as it allows you to set the size where you can't at present,
> |  nor with this patch.
> Oops, this is going into an entirely wrong direction! The posting is not about patches,
> it presented a strategy for discussion, and sums up an extract of the reading I have been
> stuck with for a couple of days.

You are posting onto a development list with a patch. Of course I am
going to discuss the patch. If you had posted to the discussion
without the patch my answer would have been very different!

> Frankly, I am really sorry that this should evolve into a discussion regarding whose patches
> are better - such was never my intention. You have put in a lot of work into these patches,
> despite having other work to do, and this in itself really is very commendable.

I wasn't talking about the quality of code etc. I was talking about
experimental results. With only that one patch it would have broken my
research that I am doing. If it had been carried through to all it
would have been fine.
>
> Lastly, can you please go back one posting and look through said patch - it does not
> even touch the default settings you are mentioning; all it does is removing the PACKET_SIZE
> socket option. This is the code I am actually using myself and have sent it as an aid; since
> it is now decoupled from other issues (please do have a look).
>
Agree - but my code allowed the PACKET_SIZE option to work. Until
yours is completed my series of patches works better. It is not
compulsory to use the option under my code so no loss. I totally think
your idea is better than my implementation. However as Dave M says
"show me the code" - i.e. fully coded good ideas are better than half
coded great ideas.

> Sorry, I was not able to produce the full works, reading up on this fixed `s' issue and
> resolving the contradictory statements in RFC 3448/4340/4342 (plus CCID 4 draft) ate away
> a lot of time that could have been spent implementing.
>
Not my fault. I was debating the code not the ideas. Don't take it
personally. With the research you've come up with I think you're
smarter than me!

> I further understand that you are working on the CCID-3 code and therefore wanted to
> bring up the strategy/discussion first.
>
> What I am currently working on is tidying up the general socket API. This involves:
>   * default fallback service code   [done]
>   * removing the PACKET_SIZE option [this discussion/posting]
>   * setting the CCIDs via socket option and poll the actual CCID via getsockopt [tbd]
>   * fitting partial-checksum coverage into the code [in progress]
>   * any other reasonable suggestions which may help getting application programming started
>     [since: no stable API --> no coherent API documentation --> no application programs]
>
> Once this is wrapped up I intend to update the documentation on the API, in form of a `DCCP
> socket programming mini HowTo', to be put online or added to the existing documentation.
> With the help of constructive discussion this may happen.
>
Yes this would be useful.
>
> To summarise:
> -------------
> 1) The real problem is not in patches - RFC 4340..2 are elusive and in parts outright wrong
>    about assumptions on the packet size. Substantial evidence that for instance using MSS
>    as fixed `s' is detrimental was provided in the last posting.

Agree 100% as you can see in my other posting. I think packet size/sec
is better for CCID3 but not allowed.

> 2) Weighted average was introduced as a strategy to resolve this in an implementable format.

Agree this is better.

> 3) Can we reach agreement regarding that PACKET_SIZE option does not help with the `fixed s'
>    issue and therefore it is OK to remove it???

No we can't. Until point 2) is done or a packet/sec implementation
then I would like my code in as it solves a real problem for me and
others. I think your option 2 if coded would be better than my code
though so happy to have yours in if coded soon otherwise I would like
mine in.

> 4) Literature research as per previous posting prevented coming up with patch. If you would
>    rather not work on it and no one else is interested, I will try to find some free time.
>
Up to you. At the moment Real Life (tm Arnaldo) has intervened and I
can't whip up patches quickly.

> -Gerrit
>
Ian

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
