From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 05 Dec 2007 13:55:11 +0000
Subject: Re: [PATCH v2 0/3][BUG-FIX]: Test tree updates and bug fixes
Message-Id: <20071205135511.GD893@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > @@ -788,8 +782,8 @@ static void ccid3_hc_rx_packet_recv(stru
| >  	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
| >  		if (is_data_packet) {
| >  			do_feedback = FBACK_INITIAL;
| > +			hcrx->ccid3hcrx_s = payload_size;
| >  			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
| > -			ccid3_hc_rx_update_s(hcrx, payload_size);
| 
| We have to set ccid3hcrx_bytes_recv to the payload_size here too, I'm
| fixing this on the reworked patch that introduces the RX history.
| 
I almost did the same error again by wanting to agree too prematurely.

But updating ccid3hcrx_bytes_recv is in fact not needed here and if it
would be done it would not have a useable effect. The reason is that the
first data packet will trigger the initial feedback; and in the initial
feedback packet X_recv (which is ccid3hcrx_bytes_recv / the_time_spent)
is set to 0 (RFC 3448, 6.3).

For this reason, updating bytes_recv for the first data packet is also not
in the flowchart on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/
