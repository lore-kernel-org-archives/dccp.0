From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 07 Feb 2012 04:10:42 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <20120207041042.GA5923@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I went through the test tree code again. It is possible that X_calc = 0 when p > 0,
but it could mask another bug. There are two conditions which could trigger this

 a) tx_s = 0
    Packets with skb->len = 0 can not be sent since ccid3_hc_tx_send_packet() returns
    EBADMSG in this case. The only possibility for tx_s then to become 0 is if
    * CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_MPS has been chosen to measure the packet size,
    * dccp_sk(sk)->dccps_mss_cache is 0 for some strange reason.
    This could be tested by adding 
       WARN_ON(dccp_sk(sk)->dccps_mss_cache = 0);
    just before the 'return' in ccid3_hc_tx_measure_packet_size(). It would be very
    helpful to find out whether this is the trigger.

 b) The value of tx_s in bytes is less than the value of the RTT in seconds
    This would cause scaled_div(tx_s, RTT) to return 0 and consequently set x_calc = 0.
    Due to DCCP_SANE_RTT_MAX, this would occur for packet sizes of 1 or 2 bytes.

The first case is the one to avoid. Could you turn on debugging by
 * activating 
   CONFIG_IP_DCCP_CCID3_DEBUG=y
   CONFIG_IP_DCCP_DEBUG=y
 * adding debug via
   echo Y > /sys/module/dccp/parameters/ccid3_debug
   echo Y > /sys/module/dccp/parameters/dccp_debug 
 * watching the /var/log/messages or /var/log/kern.log

I have been using CONFIG_IP_DCCP_CCID3_MEASURE_S_AS_MPS for a long time and never experienced
a 0 value, but it does not mean it can never happen.

Before committing to a fix that removes the BUG_ON, it is better to find out where the problem
is coming from. If (a) can be ruled out, I will check through again and see if it is safe to
allow x_calc = 0 -- a quick look seems to imply that it would work.

However, tx_s = 0 must be avoided at all cases, since it can cause division-by-zero in
ccid3_update_send_interval().

Gerrit
