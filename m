From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 11 Dec 2006 09:53:16 +0000
Subject: Re: [PATCH] BUG-FIX - conversion errors
Message-Id: <20061211095316.GE25274@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <200612081532.21104@strip-the-willow>
In-Reply-To: <200612081532.21104@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Dec 11, 2006 at 09:03:09AM +0000, Gerrit Renker wrote:
> Quoting Ian McDonald:
> |  Do we calculate mss anywhere?
> Yes there is support in dccps_mss_cache .
> At the begin of dccp_send_msg e.g. it is used. 

Yup, look at dccp_sync_mss() used in dccp_connect_init():

dccp_sync_mss(sk, dst_mtu(dst));

dccp_init_sock also sets it to a default value (same as for TCP in
tcp_v4_init_sock) and sets the struct inet_connection_sock (TCP and DCCP
have this same common ancestor class) -icsk_sync_mss() method (function
pointer 8) ) to dccp_sync_mss(), this allows the IPv4 and V6 transport
protocol independent setsockopt code to sync the mss when IP_OPTIONS is
set by apps, making sure ->icsk_ext_hdr_len is correctly taken into
account when the MSS is calculated (see net/ipv4/ip_sockglue.c &
net/ipv6/ipv6_sockglue.c).

Having said that look at dccp_sync_mss, there is a big FIXME, this one:

----------------- 8< -------------

        int mss_now = (pmtu - icsk->icsk_af_ops->net_header_len -
                       sizeof(struct dccp_hdr) -
		       sizeof(struct dccp_hdr_ext));

        /* Now subtract optional transport overhead */
        mss_now -= icsk->icsk_ext_hdr_len;

        /*
	 * FIXME: this should come from the CCID infrastructure, where,
	 * say, TFRC will say it wants TIMESTAMPS, ELAPSED time, etc,
	 * for now lets put a rough estimate for NDP + TIMESTAMP +
	 * TIMESTAMP_ECHO + ELAPSED TIME + TFRC_OPT_LOSS_EVENT_RATE +
	 * TFRC_OPT_RECEIVE_RATE + padding to
	 * make it a multiple of 4
         */

        mss_now -= ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;

        /* And store cached results */
        icsk->icsk_pmtu_cookie = pmtu;
        dp->dccps_mss_cache = mss_now;

----------------- 8< -------------

Infrastructure wise I guess struct ccid_operations should have a...
lemme read the relevant part of 4340... there CCMPS:

----------------- 8< -------------
14.  Maximum Packet Size

   A DCCP implementation MUST maintain the maximum packet size (MPS)
   allowed for each active DCCP session.  The MPS is influenced by the
   maximum packet size allowed by the current congestion control
   mechanism (CCMPS), the maximum packet size supported by the path's
   links (PMTU, the Path Maximum Transmission Unit) [RFC1191], and the
   lengths of the IP and DCCP headers.
----------------- 8< -------------

something like adding a 'ccid_mps' member to struct ccid_operations,
that would be set at suitable places in the CCID code and would be used
by icsk->icsk_sync_mss(), that could be called from ccid code when and
if the ccid code thinks it should change this value, which I guess its
just at connection setup, but could be at any time.

> I have thought about `s' vs. MSS and it is really stupid not to use MSS
>  -- if `s' is e.g. 20 bytes, one can only send 40 ... 80 bytes per RTT
>  -- with jumbo ethernet cards the MTU can be as high as 10k -- a multiple of 20 bytes :)

Yup :-)

- Arnaldo
