From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 19:18:02 +0000
Subject: Re: [PATCH v2 1/1][UPDATE]: [CCID2]: Remove redundant BUG_ON
Message-Id: <5640c7e00709251218v7f181656o61c8b911d24cae5a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709251103.00966@strip-the-willow>
In-Reply-To: <200709251103.00966@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/25/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This is a resubmission for the test tree, the change to version 2 is that
> ssthresh has, after cwnd, also been converted to u32; which suggested itself
> since there are many operations and comparisons between these two variables.
>
>
> -----------------------------> Patch v2 <-----------------------------------
> [CCID2]: Remove redundant BUG_ON
>
> This removes a test for `val < 1' which would only have been triggered
> when val < 0, due to a preceding test for 0.
> Fixed by using an unsigned type for cwnd (as in TCP) instead.
> Since ssthresh derives from cwnd and appears in assignments and comparisons,
> the type of ssthresh was changed to matched that of cwnd.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
