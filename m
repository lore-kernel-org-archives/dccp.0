From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 12 May 2008 10:26:37 +0000
Subject: Re: CCID4 Testing - bug fix
Message-Id: <20080512102637.GA4638@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <09D3F703EF3B0A4CBE28449EA9F3D32009EB46E6@nicta-atp-mail.in.nicta.com.au>
In-Reply-To: <09D3F703EF3B0A4CBE28449EA9F3D32009EB46E6@nicta-atp-mail.in.nicta.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Patch details: we modify the sender rate in the initial phase when
| congestion control is not yet applied. In the original code, the header
| penalty rate reduction of s/(s+overhead) was, I believe, incorrectly
| applied to all sender rates. 

| Otherwise you eventually throttle the rate to a very low rate as the growth
| governed by min(2*X, 2*Xrec) cannot work when the header penalty is less
| than 0.5 - in this case you shrink rather than grow. 
| 
| Example: header penalty for a 20b packet is 20/56=0.357. On RTT of
| 200msec, the initial rate is 3.2kbit/s, assuming the receiver gets this
| rate, you grow to 2*Xrec*header penalty, which is 2.28kbit/s, etc till
| you reach the min rate of s/RTT.
|
The point is correct this: would happen for all payload sizes s < 36
bytes (which applies to VoIP packets). In this case the increase factor
during slow-start is indeed less than 1 and moves from exponential
increase to decrease.

The CCID4-02 draft indeed speaks of "allowed transmit rate derived from
the TCP throughput equation" in section 5, which seems to imply that X_calc
(and not X in general) is meant, which confirms your interpretation.

| 
| Is it possible to contribute to the ccid4 tree, or (for Gerrit) would
| you like us to send you the patch which is not a large number of lines. 
| 
Please do send a patch, since this gives the other CCID-4 developers a
chance to sign this off.

Since the reduction applies to X_calc only, IMHO it should be moved like this:

	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
        if (hctx->p > 0) {
		hctx->x_calc = tfrc_calc_x(NOM_PACKET_SIZE, 
					   hctx->rtt, hctx->p);

		/* Apply header penalty as per RFC 4828, 4.2 */
		hctx->x_calc *= hctx->s;
		do_div(hctx->x_calc, hctx->s + CCID4HCTX_H);
	}

and then remove the ccid4_hc_tx_x_header_penalty() function since it is
now called in one place only.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

