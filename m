From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 16 Jun 2007 23:07:09 +0000
Subject: Re: [PATCH 5/6]: Add history query/lookup function
Message-Id: <5640c7e00706161607k4362f72dte1a8a521cc145f5e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706111342.02233@strip-the-willow>
In-Reply-To: <200706111342.02233@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [TFRC]: Add history query/lookup function
>
> This completes the basic TX history functions that are implemented by this
> patch set, by adding a lock-protected lookup function to look up the send
> time of a particular sent packet.

I notice there is other functionality here also...

> +/**
> + *  tfrc_tx_hist_when  -  Retrieve send time of past packet
> + *  If successful, it garbage-collects older (irrelevant) entries and returns 1.
> + */
> +int tfrc_tx_hist_when(ktime_t *stamp, struct tfrc_tx_hist_head *head, u64 ackno)
> +{
> +
> +       if (tail)
> +               __tfrc_tx_hist_remove_tail(tail, head->cache);
> +

Can you explain the rationale behind this?

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
