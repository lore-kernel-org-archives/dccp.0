From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 10 Jan 2007 03:14:57 +0000
Subject: Re: [SUMMARY]: Problems with loss interval recalculation / audit against [RFC 3448, 5.4]
Message-Id: <5640c7e00701091914l1c06f1aevf44778bcf45653e2@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701051829.20415@strip-the-willow>
In-Reply-To: <200701051829.20415@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 09/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Hence the detection of a loss event always triggers insertion of the sequence number
> and timestamp at the head of the list.
> With regard to your above comment, we should probably change this so that I_0 is
> not stored on top of the list - or adapt the list handling so that I_0 can be distinguished
> from I_1 ... I_k (k <= 8).
>
I_0 is not stored at the head of the list. It is stored in non-loss. I
can understand the confusion as my code wasn't clear.

> So I think what we can take home as `todo' items from this is
>  * correct the list handling with regard to I_0
>  * ensure that I_1 ... I_8 all fit in the list
>  * compute the interval length I_0 as done for `non_loss' in Ian's patch
>  * change the summation loop so that it matches the one in the RFC
>

I've changed all the code to match the RFC and added a few more
comments. I believe my logic was correct but extremely confusing as
I'd reversed i_tot0 and i_tot1 meanings not to mention how I had done
the loop counters!! I've not made it so you can read along the RFC
even though the same thing is done.

I'm glad to tidy this up as this was a bit messy in BSD, got munted in
the change to Linux. Being in arrays would help clarity (but not
results) quite a bit further I think too.

Patch to follow.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
