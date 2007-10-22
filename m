From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 22 Oct 2007 14:50:50 +0000
Subject: Re: [RFC]: field name identifier conventions
Message-Id: <200710221550.50989@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200710201654.35326@strip-the-willow>
In-Reply-To: <200710201654.35326@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks everyone for replying, below is the summary of earlier emails.


1) Ian wrote:
|  I think the best way to do this is once Arnaldo agrees and then
|  prepare a big patch to do this. If we don't get Arnaldo's buy in then
|  it will be hell to maintain the patch set. 
Fully agree - Arnaldo is the maintainer and as such it is up to him to decide on such things
affecting global consistency. If there is a new naming scheme which finds his approval, I am
more than happy to update the entire test tree, but if not I wouldn't like to change
the patches: these should reflect the existing DCCP style/conventions.

2) All agreed that the naming scheme could be changed.

3) There are the following suggestions:
   * Arnaldo: "->c2tx_"
   * Leandro: "tx->c4"

  If we combine these suggestions, considering that for the CCID sockets this will be likely
  `hcrx' for RX sockets and `hctx' for TX sockets (like referring to struct sk_buff as skb),
  then Leandro's scheme is nice and small:

	* hcrx->c3_last_counter
	* hcrx->c4_last_counter
	* hctx->c3_last_win_count
	* hctx->c4_no_feedback_timer

  In conclusion, what about the following naming scheme:?

	* hctx->c"N"_FIELDNAME		/* N = CCID number, 0..255 */
	* hcrx->c"N"_FIELDNAME
	*  avr->avr_FIELDNAME		/* r for record ? */
	*   av->av_FIELDNAME		/* or drop the `av/avr' ? */

  The actual patch will probably cost less work than making this scheme consistent.
