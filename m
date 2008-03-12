From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Mar 2008 08:06:33 +0000
Subject: Re: dccp bugs (Was: Re: panic on 2.6.24rc5)
Message-Id: <20080312080633.GA4996@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
List-Id: <dccp.vger.kernel.org>
References: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
To: dccp@vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Can you do me a favour and give the attached patch a try, on your virtual
environment: this is a simpler solution.

I have tested it on loopback and found that some of the instabilities
disappear when clamping the RTT to a minimum value.

Fixing this is important even if it is "only" loopback: the problem will
re-appear on other high-speed interfaces.

--2oS5YaxWCcQjTEyO
Content-Type: text/x-diff; charset=us-ascii
Content-Description: RTT-clamping patch (should apply on test tree as well as mainline)
Content-Disposition: attachment; filename="min-rtt.diff"

[DCCP]: Ignory tiny RTTs

This lets DCCP ignore small RTT samples, by clamping all tiny values to 
a minimum of 100 microseconds.

The impetus for this patch was instabilities which were observed in conjunction
with small RTTs in the CCID-3 module.

The chosen minimum of 100 microseconds is open to suggestion - it would be
possible to chose a higher value, on the other hand it seems not worth making
the single value a Kconfig option.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -710,15 +710,12 @@ u32 dccp_sample_rtt(struct sock *sk, lon
 	/* dccpor_elapsed_time is either zeroed out or set and > 0 */
 	delta -= dccp_sk(sk)->dccps_options_received.dccpor_elapsed_time * 10;
 
-	if (unlikely(delta <= 0)) {
-		DCCP_WARN("unusable RTT sample %ld, using min\n", delta);
+	if (unlikely(delta < DCCP_SANE_RTT_MIN))
 		return DCCP_SANE_RTT_MIN;
-	}
 	if (unlikely(delta > DCCP_SANE_RTT_MAX)) {
 		DCCP_WARN("RTT sample %ld too large, using max\n", delta);
 		return DCCP_SANE_RTT_MAX;
 	}
-
 	return delta;
 }
 

--2oS5YaxWCcQjTEyO--
