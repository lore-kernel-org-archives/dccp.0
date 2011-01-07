From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 07 Jan 2011 11:28:37 +0000
Subject: Re: Sequence Number Validation Bug Fixes 2/2
Message-Id: <20110107112837.GA5315@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1293393024.22785.1.camel@jero-laptop>
In-Reply-To: <1293393024.22785.1.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| I am now in agreement with the patch as below.
Thanks a lot for checking again, and also for the two bug fixes. Both were
excellent catches, I am going to submit them now. One less bug to think about.

Gerrit
| 
| > 
| > | > >>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
| > | > dccp: fix bug in updating the GSR
| > | > 
| > | > Currently dccp_check_seqno allows any valid packet to update the Greatest
| > | > Sequence Number Received, even if that packet's sequence number is less than
| > | > the current GSR. This patch adds a check to make sure that the new packet's
| > | > sequence number is greater than GSR.
| > | > 
| > | > Signed-off-by: Samuel Jero <sj323707@ohio.edu>
| > | > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
| > | > ---
| > | >  net/dccp/dccp.h |    3 ++-
| > | >  1 file changed, 2 insertions(+), 1 deletion(-)
| > | > 
| > | > --- a/net/dccp/dccp.h
| > | > +++ b/net/dccp/dccp.h
| > | > @@ -426,7 +426,8 @@ static inline void dccp_update_gsr(struc
| > | >  {
| > | >  	struct dccp_sock *dp = dccp_sk(sk);
| > | >  
| > | > -	dp->dccps_gsr = seq;
| > | > +	if (after48(seq, dp->dccps_gsr))
| > | > +		dp->dccps_gsr = seq;
| > | >  	/* Sequence validity window depends on remote Sequence Window (7.5.1) */
| > | >  	dp->dccps_swl = SUB48(ADD48(dp->dccps_gsr, 1), dp->dccps_r_seq_win / 4);
| > | >  	/*
