From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 19:16:56 +0000
Subject: Re: [PATCH 5/10]: Consistently update t_nom, t_ipi, t_delta
Message-Id: <200611271916.56334@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.41268@strip-the-willow>
In-Reply-To: <200611241619.41268@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 11/25/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > [CCID 3] Consistently update t_nom, t_ipi, t_delta
|  >
|  Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
|  
|  >  * ties updating these parameters to updating the sending rate X, exploiting
|  >    that all three parameters in turn depend on X; and using a small optimisation
|  >    which can reduce the number of required instructions: only update the three
|  >    parameters when X really changes
|  >
|  Do we need to worry about s changing though with the other patches you
|  have introduced as it is also dependent on s....
Yes we do need to worry about those things. This is why I retracted an earlier patch
which did not seed `s' and sent an update. In that update I was confident that I had
ironed out ill conditions arising from non-initialised and zero-valued `s'. 


It is easy to update x whenever `s' changes, but I have not done so, as explained in 
the following comment from ccid3_hc_tx_update_s():

	/* Note: We could do a potential optimisation here - when `s' changes,
	         recalculate sending rate and consequently t_ipi, t_delta, and
		 t_now. This is however non-standard, and the benefits are not
		 clear, so it is currently left out.                          */

If you wanted to test this, it is actually easy; in ccid3_hc_tx_update_s():

	u32 old_s  = hctx->ccid3hctx_s;

	/* ... as before ... */

	if (old_s  != hctx->ccid3hctx_s)
		ccid3_update_send_time(hctx);


	/* end of ccid3_hc_tx_update_s() */

This, as said, is however experimental - so I have left it out.

Gerrit
