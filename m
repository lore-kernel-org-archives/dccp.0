From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 29 Nov 2006 16:51:54 +0000
Subject: Re: CCID 3: Strategy for removing division bugs and division errors
Message-Id: <5640c7e00611290851n2ff43807i26cea912949c8fe8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611291515.46613@strip-the-willow>
In-Reply-To: <200611291515.46613@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Haven't read this all yet (and won't for a few hours) but a couple of things:

On 11/30/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> The detailed derivation is below, I am putting this into patches at the moment. It
> would be good to have this codified before Ian starts testing.

My testing is not one off. There have been lots of changes so I expect
to do multiple rounds if there are problems.
>
>   (a) Problem 1: Overflow
>       -------------------
>       Since currently receive/sending rates are stored as u32, this leads to overflow.

Have a look at http://master.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;ha7a3ba6608de6e0c0bfe3009a63d7e0b7ab0ce
for how it used to be in case it helps.

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
