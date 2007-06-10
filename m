From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 10 Jun 2007 06:05:07 +0000
Subject: Re: [PATCH 3/3]: Update computation of X to use newer timeofday interface
Message-Id: <5640c7e00706092305u4e1aef31o4d436c28310177d5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091933.09514@strip-the-willow>
In-Reply-To: <200706091933.09514@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/10/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Update computation of X to use newer timeofday interface
>
> This updates the timestamping references in the computation of X to the newer
> ktime_t interface. The time-last-doubled t_ld is now also upgraded to ktime_t;
> furthermore up-to-date comments were added to ccid3_hc_tx_update_x().
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This looks OK but...
> -static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
> +static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
>
I don't see callers updated. Is this what you mean by patches being
interdependent?

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
