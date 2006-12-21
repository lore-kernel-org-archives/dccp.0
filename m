From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Dec 2006 14:06:41 +0000
Subject: Re: [PATCH 4/5]: DCCP Fix t_nom
Message-Id: <200612211406.41981@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201548.12544.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201548.12544.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  When we recalculate t_nom and t_ipi we should check that t_nom is not
|  before the current time. If it is then we should set t_nom to current time.
|  
|  Found this by observing flood of packets when t_ipi decreases.
In any case, you have found a bug, thank you for spotting this. However, there
are several problems with this.
 1) t_nom < t_now is a BUG condition and should never happen (i.e. this fixes a symptom, 
    the bug is somewhere else)
 2) the way t_nom is (re-)calculated is as follows: 

   * First packet:
     t_0 = t_now             [in ccid3_hc_tx_send_packet, state TFRC_SSTATE_NO_SENT]

   * second ... n-th packet:
     t_nom = t_nom + t_ipi   [end of ccid3_hc_tx_send_packet]

   * modification of t_nom due to change in s or X:
     t_nom = t_nom - t_ipi_old + t_ipi_new
           = t_nom - (t_ipi_old - t_ipi_new)

     ==> That means, t_nom can only be before t_now, if t_ipi_new > t_ipi_old. 
          This would contradict the condition you stated (t_ipi_new < t_ipi_old).
          I have a suspicion that this is actually due to nofeedbacktimer over-activity,
          so it hacks away at the send time. 

 3) calling do_gettimeofday via dccp_timestamp is an expensive operation and should be 
    avoided. 
 4) can you please reinvestigate and confirm this condition. If it is indeed true and not caused
    by other factors (logically it seems impossible); then we have to bite the bullet and redesign
    the entire send_packet interface once again. This relates to previous comments by Eddi, Colin
    Perkins, Mark Handley, and (by personal communication), Gorry, which
    amount to not using gettimeofday to recalculate send time via nofeedback timer.
    I had hoped to avoid this since there are many bugs in other sections which then will have to
    wait longer. 
 
The consequence: this is a symptom-fix, not a bug fix. The bug is somewhere else and requires
to redesign the entire sending interface from scratch. It would greatly help if you could tell
us under which conditions and in which call sequence you have observed that t_nom < t_now.

  
|  Also uninline the function as it is big and gcc should decide when to
It does not contain loops, conditionals or nested statements (before it was really tiny).

  
|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
But: I have made the below modification in the online version.


|  +	delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
|  +	if (delay < 0) {
|  +		hctx->ccid3hctx_t_nom = now;
|  -		ccid3_pr_debug("reset t_nom\n");
   +            DCCP_BUG("t_nom < t_now: RESET");                       	
|  +	}
