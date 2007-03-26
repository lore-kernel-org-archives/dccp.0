From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 26 Mar 2007 03:31:45 +0000
Subject: Re: [PATCH 21/25]: Wait for CCID
Message-Id: <5640c7e00703252031i56db5ecdi3c168f5b86509cf2@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211845.52465@strip-the-willow>
In-Reply-To: <200703211845.52465@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/22/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Wait for CCID
>
> This performs a minor optimisation: when ccid_hc_tx_send_packet returns
> a value greater zero, then the same call previously was done again at the
> begin of the while loop in dccp_wait_for_ccid.
>
> This patch exploits the available information and schedule-timeouts directly
> instead.
>
> Documentation also added.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Great spotting. I had noticed that ccid_hc_tx_send_packet had been
getting called needlessly before and this should fix that.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
