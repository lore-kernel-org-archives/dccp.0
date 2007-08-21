From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 13:17:02 +0000
Subject: Re: [PATCH 07/15] Convert dccp_sample_rtt to ktime_t
Message-Id: <200708211417.03084@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070819235043.GK24792@ghostprotocols.net>
In-Reply-To: <20070819235043.GK24792@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

After a bit more testing, I found that this one has one bug.

|  @@ -593,22 +591,21 @@ EXPORT_SYMBOL_GPL(dccp_rcv_state_process);
|    * @t_recv: receive timestamp of packet with timestamp echo
|    * @t_hist: packet history timestamp or NULL
|    */
|  -u32 dccp_sample_rtt(struct sock *sk, struct timeval *t_recv,
|  -				     struct timeval *t_hist)
|  +u32 dccp_sample_rtt(struct sock *sk, ktime_t t_recv, ktime_t *t_hist)
|   {
|   	struct dccp_sock *dp = dccp_sk(sk);
|   	struct dccp_options_received *or = &dp->dccps_options_received;
|  -	suseconds_t delta;
|  +	s64 delta;
|   
|   	if (t_hist = NULL) {
|   		if (!or->dccpor_timestamp_echo) {
|   			DCCP_WARN("packet without timestamp echo\n");
|   			return DCCP_SANE_RTT_MAX;
|   		}
|  -		timeval_sub_usecs(t_recv, or->dccpor_timestamp_echo * 10);
|  -		delta = timeval_usecs(t_recv);
|  +		ktime_sub_us(t_recv, or->dccpor_timestamp_echo * 10);
|  +		delta = ktime_to_us(t_recv);
=> It should read
    t_recv = ktime_sub_us(t_recv, or->dccpor_timestamp_echo * 10);
    the statement is otherwise void.

