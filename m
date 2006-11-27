From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 12:31:20 +0000
Subject: Re: [PATCH 2/6]: Simplify control flow in the calculation of t_ipi
Message-Id: <200611271231.20662@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.18544@strip-the-willow>
In-Reply-To: <200611211545.18544@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > [CCID 3]: Simplify control flow in the calculation of t_ipi
<snip>
|  >  In addition, a problematic comment in ccid3_calc_new_t_ipi() was removed:
|  >    * the first part of the comment (initial t_ipi = 1 second) is correct
|  >    * the second part of the comment is not correct wrt. [RFC 3448, 4.4]
|  
|  Why is the second part of the comment wrong?
|  
|  RFC 3448, 4.4:
|  
|  4.4.  Expiration of nofeedback timer
|  
|     If the nofeedback timer expires, the sender should perform the
|     following actions:
|  
|     1) Cut the sending rate in half.  If the sender has received feedback
|        from the receiver, this is done by modifying the sender's cached
|        copy of X_recv (the receive rate).  Because the sending rate is
|        limited to at most twice X_recv, modifying X_recv limits the
|        current sending rate, but allows the sender to slow-start,
|        doubling its sending rate each RTT, if feedback messages resume
|        reporting no losses.
|  
|  If the sending rate is halved, doesn't it implies the inter packet
|  interval is doubled?
Yes that is right. Ian, I apologise - you were correct in this comment. 
Will re-send an update.
