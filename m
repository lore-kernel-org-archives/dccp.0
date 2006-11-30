From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 30 Nov 2006 18:08:26 +0000
Subject: Re: [DCCP]: Fix BUG in send time calculation
Message-Id: <5640c7e00611301008l4fa2ce6dmcb34a85b0abc49b6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611301541.36467@strip-the-willow>
In-Reply-To: <200611301541.36467@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/1/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I think I found the bug, see description below.
> The problem was clearly in CCID 3, with CCID 2 performance was good.
> I think it makes sense to use the other patch (RTO) as well. CCID 3
> needs some more work, but I think with this the reported problem is
> solved.
>
> ------------> Commit Message <---------------------------------
> [DCCP]: Fix BUG in retransmission delay calculation
>
I'd just found the same patch being faulty using git-bisect so I agree...

-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
