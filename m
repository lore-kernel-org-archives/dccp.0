From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 07 Aug 2007 21:59:43 +0000
Subject: Re: Comments/question on no_feedback_timer
Message-Id: <5640c7e00708071459l75bad171w98d649020d1ea023@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00708021614j780c829ao3ce950b25c8ac67@mail.gmail.com>
In-Reply-To: <5640c7e00708021614j780c829ao3ce950b25c8ac67@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/7/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  And the more I look at it the bigger my headache. I'm going to have to
> |  start doing some of the TFRCbis rev02 stuff given the intertwining
> |  with Faster Restart.
> I take it that you are aware that the authors of the Faster Restart draft
> are in the process of replacing the current version with an entirely different one
> based on cwnd window validation. I'd check with the authors for their time plan.
>
No! I just checked Sally's slides from IETF meeting held and it didn't
mention this at all. Where did you get this from?

> Having rev02 in full length (and provided feedback), I found other issues in rev02.
> There are a couple of things (such as receive-sets) which make implementation even more
> complex. Plus, the situation is like Faster-Restart: the draft is in a volatile state,
> some feedback (after recent IETF) seems to not have been addressed, the next rev is due
> in December, and only after the IETF meeting can some convergence/clarity be expected.
>
Yes I agree receive sets are complex. I didn't see your feedback -
maybe I didn't look properly - can you send to me?

> |  I'll probably post back patches from time to time that you can do what
> |  you want with. (Ignore, integrate or somewhere in between)
> I'd say, we put this up as a fork of the DCCP test tree?
>
However you want to handle is fine.

> If you encounter issues or problems with the test tree and there are things
>             - outside the rev00 and rev02 discussion -
> which can make the test tree better, then of course this goes into the test tree.
>
> But due to the entanglements, I'd much prefer to keep rev00 and rev02 code separate
> from each other.
>
Understand.

-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
