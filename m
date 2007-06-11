From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 11 Jun 2007 08:34:30 +0000
Subject: Re: [PATCH 1/3]: Inline for time delta
Message-Id: <5640c7e00706110134y9fe0311v558fb5f20137e398@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091932.15559@strip-the-willow>
In-Reply-To: <200706091932.15559@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/11/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>
> Neither place seems appropriate for above function, it is more specific than the
> ones in ktime.h. I am at a loss where else if not the DCCP code, where it is
> specifically used, to place it.
>
> The name was chosen for consistency with timeval_delta(), which is the current
> function for microsecond time differences in net/dccp/dccp.h.
>
I'm fine with it myself. Just commenting on recent stuff in netdev.
Keep it as is for now if nowhere else is better.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
