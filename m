From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 25 Sep 2007 11:35:27 +0000
Subject: Re: [PATCH v2  4/5]: Rate-limit DCCP-Syncs
Message-Id: <20070925113527.GA18348@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200709251058.41805@strip-the-willow>
In-Reply-To: <200709251058.41805@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Sep 25, 2007 at 10:58:41AM +0100, Gerrit Renker escreveu:
> Arnaldo -
> 
> |  Algorithm is fine, just use time_after when comparing jiffies based
> |  timestamps, here:
> Many thanks for pointing this out - it was a stupid oversight. The interdiff
> to the previous patch is:
> 
>  		 *   These Syncs are rate-limited as per RFC 4340, 7.5.4:
>  		 *   at most 1 / (dccp_sync_rate_limit * HZ) Syncs per second.
>  		 */
> -		if (now - dp->dccps_rate_last >= sysctl_dccp_sync_ratelimit) {
> +		if (time_after(now, dp->dccps_rate_last 
> +				  + sysctl_dccp_sync_ratelimit)) {
>  			dp->dccps_rate_last = now;
>  			/* ... */
> 
> I have only compile-tested this, but verified twice on paper, and it looks correct
> (the `>=' has been replaced with `>', using `time_after_eq' does not seem necessary).
> Please find update below.

Thanks, some nits below:
 
>  
> --- a/net/dccp/sysctl.c
> +++ b/net/dccp/sysctl.c
> @@ -18,6 +18,9 @@
>  #error This file should not be compiled without CONFIG_SYSCTL defined
>  #endif
>  
> +/* rate-limit for syncs in reply to sequence-invalid packets; RFC 4340, 7.5.4 */
> +int sysctl_dccp_sync_ratelimit	__read_mostly = HZ / 8;

Why the extra spaces/tabs before __read_mostly? Don't worry about this
one or the other ones you submitted so far, I'll eventually do a coding
style cleanup once the number of outstanding patches gets to some
manageable level, but please take this in consideration for your next
patches, ok? One more:

> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> +		if (time_after(now, dp->dccps_rate_last
> +				  + sysctl_dccp_sync_ratelimit)) {

In linux networking code what has been the most accepted form for
multiline expressions is:

		if (time_after(now, (dp->dccps_rate_last +
				     sysctl_dccp_sync_ratelimit))) {

Either form produces the same code, but as the later is what I, David
and others are most confortable with and have been using for quite a
while, please try to get used to doing it this way, ok?

Thanks!

- Arnaldo
