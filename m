From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 18 Sep 2007 07:47:38 +0000
Subject: Re: [PATCH 5/5]: Fix Request/Response RTT sampling
Message-Id: <5640c7e00709180047v4e6eecf9jd40c7cc2de744f84@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200709121535.17746@strip-the-willow>
In-Reply-To: <200709121535.17746@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Ian McDonald:
> |  On 9/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  > [DCCP]: Fix Request/Response RTT sampling
> |  >
> Thanks for looking at this, but I won't/can't use the sign-off, since
> I merged this patch with the one which had the error fixed by this patch.
>
OK. Reviewed the merged patch now.

> ---------------------> Updated Patch #3, fixed by 5/5 <-----------------------
> [DCCP]: Simplify interface of dccp_sample_rtt
>
> The third parameter of dccp_sample_rtt now becomes useless and is removed.
>
> Also combined the subtraction of the timestamp echo and the elapsed time.
> This is safe, since (a) presence of timestamp echo is tested first and (b)
> elapsed time is either present and non-zero or it is not set and equals 0
> due to the memset in dccp_parse_options.
>
> To avoid measuring option-processing time, the timestamp for measuring the
> initial Request/Response RTT sample is taken directly when the function is
> called (the Linux implementation always adds a timestamp on the Request,
> so there is no loss in doing this).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
