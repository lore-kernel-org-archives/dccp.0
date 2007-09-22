From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 22 Sep 2007 20:16:07 +0000
Subject: Re: [PATCH 4/5]: Rate-limit DCCP-Syncs
Message-Id: <20070922201607.GD4887@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200704091058.57313@strip-the-willow>
In-Reply-To: <200704091058.57313@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Jun 20, 2007 at 10:56:03AM +0100, Gerrit Renker escreveu:
> [DCCP]: Rate-limit DCCP-Syncs
> 
> This implements a SHOULD from RFC 4340, 7.5.4: 
>  "To protect against denial-of-service attacks, DCCP implementations SHOULD 
>   impose a rate limit on DCCP-Syncs sent in response to sequence-invalid packets, 
>   such as not more than eight DCCP-Syncs per second."
> 
> The rate-limit is maintained on a per-socket basis. This is a more stringent
> policy than enforcing the rate-limit on a per-source-address basis and
> protects against attacks with forged source addresses.
> 
> Moreover, the mechanism is deliberately kept simple. In contrast to
> xrlim_allow(), bursts of Sync packets in reply to sequence-invalid packets
> are not supported.  This foils such attacks where the receipt of a Sync
> triggers further sequence-invalid packets. (I have tested this mechanism against
> xrlim_allow algorithm for Syncs, permitting bursts just increases the problems.)
> 
> In order to keep flexibility, the timeout parameter can be set via sysctl; and
> the whole mechanism can even be disabled (which is however not recommended).
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Algorigthm is fine, just use time_after when comparing jiffies based
timestamps, here:


>  		 */
> -		if (dh->dccph_type = DCCP_PKT_RESET)
> -			seqno = dp->dccps_gsr;
> -		dccp_send_sync(sk, seqno, DCCP_PKT_SYNC);
> +		if (now - dp->dccps_rate_last >= sysctl_dccp_sync_ratelimit) {
> +			dp->dccps_rate_last = now;
> +

Take a look at net/ipv4/syncookies.c:

struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
                             struct ip_options *opt)
<SNIP>
        if (time_after(jiffies, tp->last_synq_overflow + TCP_TIMEOUT_INIT) ||
            (mss = cookie_check(skb, cookie)) = 0) {
                NET_INC_STATS_BH(LINUX_MIB_SYNCOOKIESFAILED);
                goto out;
        }
<SNIP>

Please resubmit with this fix and I'm ok merging it,

Thanks,

- Arnaldo
