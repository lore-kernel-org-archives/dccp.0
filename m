From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Dec 2006 21:00:46 +0000
Subject: Re: [PATCH 1/1] DCCP: Reorganise loss interval code
Message-Id: <200612212100.46293@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612220924.34663.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612220924.34663.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Applies on top of my previous patches. (So I have to convince Gerrit of the
|  merits of them first!)
I tried to apply it but it bombed out with 3 hunks failing. I like the basic idea
and have another suggestion:
 =>  dccp_li_update_li() is only called in ccid3_hc_rx_detect_loss() and there
      it is called with the arguments
      ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
	      	                hcrx->ccid3hcrx_ccval_nonloss) 

 => Since hcrx derives from sk via pointer-cast, and since the last two arguments
     are fields of hcrx, we could simplify the interface to
     ccid3_hc_rx_update_li(sk)

 => However, I am not sure that the way  ccid3_hc_rx_update_li() is called is as 
     intentioned.

But for the basic idea,
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
