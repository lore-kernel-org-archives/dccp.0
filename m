From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 24 Jun 2007 21:29:10 +0000
Subject: Re: [PATCH 4/5]: Wait for CCID
Message-Id: <5640c7e00706241429m5bdcf8b4h8ed56fcc08c44650@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706141005.13964@strip-the-willow>
In-Reply-To: <200706141005.13964@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/14/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Wait for CCID
>
> This performs a minor optimisation: when ccid_hc_tx_send_packet returns a value greater
> zero, then the same call previously was done again at the begin of the while loop
> in dccp_wait_for_ccid.
>
> This patch exploits the available information and schedule-timeouts directly instead.
>
Yes - I had noticed this also as discussed previously.

> Documentation also added.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
