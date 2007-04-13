From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 18:14:58 +0000
Subject: Re: [PATCH-UPDATE]: Changes after retracting timestamping patches
Message-Id: <200704131914.59121@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704131825.14989@strip-the-willow>
In-Reply-To: <200704131825.14989@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  The fix is in using dccp_timestamp, as in all other patches I have been updating
|  over the day. Will send this update shortly.

I have verified this - the patch set is correct. The initial RTT estimate taken from
the Request/Response exchange in net/dccp/input.c


The reason is that the patch "Cheaper & smaller timestamping" (6b) has been retracted,
i.e. the following change no longer applies

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -304,7 +304,7 @@ static int dccp_rcv_request_sent_state_p
                if (dp->dccps_options_received.dccpor_timestamp_echo) {
                        struct timeval now;

-                       dccp_timestamp(sk, &now);
+                       do_gettimeofday(&now);
                        dp->dccps_syn_rtt = dccp_sample_rtt(sk, &now, NULL);
                }


=> Which means that all timestamps are relative to dccps_epoch.

To be extra safe, I just did a test run and got

Apr 13 19:11:41 kernel: [ 3171.585188] ccid3_hc_tx_send_packet: SYN RTT = 321us

So this does work.

However, the RTTs now grow to big fat values such as several seconds. Can't help it,
that is the price of not using a realtime operating system. 
