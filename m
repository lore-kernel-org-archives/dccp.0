From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 07 Dec 2006 22:04:06 +0000
Subject: Re: [Patch 5/12]: Initialise RTT values
Message-Id: <5640c7e00612071404x7b6767cpf2c8ec0b7fa9e02c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612072112.53347@strip-the-willow>
In-Reply-To: <200612072112.53347@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/8/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Initialise RTT values

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz> once you fix the
whitespace issue you introduced below:

> @@ -1011,6 +1012,7 @@ static void ccid3_hc_rx_packet_recv(stru
>                         hcrx->ccid3hcrx_rtt = (hcrx->ccid3hcrx_rtt * 9) / 10 +
>                                               r_sample / 10;
>
> +
>                 if (rtt_prev != hcrx->ccid3hcrx_rtt)
>                         ccid3_pr_debug("%s, New RTT=%uus, elapsed time=%u\n",
>                                        dccp_role(sk), hcrx->ccid3hcrx_rtt,

-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
