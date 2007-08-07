From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 07 Aug 2007 03:02:51 +0000
Subject: Re: Comments/question on no_feedback_timer
Message-Id: <5640c7e00708062002s4cb90334v279dec5f464fa8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00708021614j780c829ao3ce950b25c8ac67@mail.gmail.com>
In-Reply-To: <5640c7e00708021614j780c829ao3ce950b25c8ac67@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/3/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Ian,
>
> to clarify - all rfc3448bis
>
> It is consistent with revision 00 of draft rfc3448bis; check against:
>  http://tools.ietf.org/html/draft-ietf-dccp-rfc3448bis-00#section-4.4
>
OK there is my issue partially. I'm working against revision 02 and
that is quite different :-(

> Here is a misunderstanding. ccid3_hc_tx_idle_rtt() measures the amount of time
> the sender has not sent anything, returned as integral number of full RTTs.
> This notion of idling is consistent with section 6.4 of RFC 4342 and further
> consistent with the definition of CCID2's quiescence in section 6.2.1 of RFC 4341.
>
> If it still seems wrong, then this is something on the level of the specification.
> It has taken painstaking effort to align the implementation with RFC 4342, 4340,
> 3448, rfc3448bis. I am quite reluctant to start tearing this apart, since it can
> not be done `fix' wise: if you do it, then the complete set of changes from rev00
> to rev02 of rfc3448bis needs to be implemented.
>
Yes I understand.

> |  Can someone else verify before I fix? I do have a habit of reading
> |  code wrong so would like verification.
> I repeat, the code is consistent with revision 00 of draft rfc3448bis, available
> from http://tools.ietf.org/html/draft-ietf-dccp-rfc3448bis-00
>
> Given the recent discussions of this, I would like to postpone such discussion until
> December, after they have reviewed the next revision of rfc3448bis.
>
OK. I don't intend to get into long discussions around individual
versions or discuss to death. I just didn't realise which version the
code was against. It creates a headache for me but that's my
problem...

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
