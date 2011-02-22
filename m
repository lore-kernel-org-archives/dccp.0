From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Feb 2011 11:33:59 +0000
Subject: Re: [PATCH 2/4] dccp: Send Confirm Options Only Once
Message-Id: <20110222113359.GC3962@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1297647877.9816.145.camel@jero-laptop>
In-Reply-To: <1297647877.9816.145.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Samuel Jero:
| Remove Feature Negotiation Confirm Options from the list of options to
| send after they are sent once because such options are NOT supposed to
| be retransmitted and are ONLY supposed to be sent in response to a
| Change Option (RFC 4340 6.2).
| 

| --- a/net/dccp/feat.c
| +++ b/net/dccp/feat.c
| @@ -690,11 +690,18 @@ int dccp_feat_insert_opts(struct dccp_sock *dp, struct dccp_request_sock *dreq,
|  			return -1;
|  		if (pos->needs_mandatory && dccp_insert_option_mandatory(skb))
|  			return -1;
| -		/*
| -		 * Enter CHANGING after transmitting the Change option (6.6.2).
| -		 */
| -		if (pos->state = FEAT_INITIALISING)
| -			pos->state = FEAT_CHANGING;
| +
| +		if (opt = DCCPO_CONFIRM_R || opt = DCCPO_CONFIRM_L) {
| +			/*Confirms don't get retransmitted (6.6.3)*/
| +			dccp_feat_list_pop(pos);
| +		} else {
| +			/*
| +			 * Enter CHANGING after transmitting
| +			 * the Change option (6.6.2).
| +			 */
| +			if (pos->state = FEAT_INITIALISING)
| +				pos->state = FEAT_CHANGING;
| +		}

Your thinking is correct, but this needs more work.

In fact your code is almost the same as the one that had been reverted earlier:

               if (pos->state = FEAT_INITIALISING)
	               pos->state = FEAT_CHANGING;
	       else if (pos->needs_confirm && dreq = NULL)
	               dccp_feat_list_pop(pos);

where the else-if part has been removed since it lead to several bugs when packets
got lost during the initial handshake. The problem is that client and server have
only 3 packets to get it right, if only 1 packet gets lost, and then retransmitted,
the negotiation does not complete.

( This part was only one half of the change, the other is in proto.c:dccp_set_state()

		/* Client retransmits all Confirm options until entering OPEN */
		 if (oldstate = DCCP_PARTOPEN)
                        dccp_feat_list_purge(&dccp_sk(sk)->dccps_featneg);
)

It seems to me that what you would like to do is to send Confirm options only once
in established state? Then the dccp_feat_list_pop() should be state-dependent, i.e.
 only apply in states > PARTOPEN. Otherwise, we will have the same bugs for the
initial feature negotiation that had already been fixed. This is documented on:

 http://eden-feed.erg.abdn.ac.uk/dccp/notes/feature_negotiation/why_retransmit_confirms

Connection-state dependent handling of negotiation options is in dccp_feat_parse_options(),
don't have a patch to accomplish both the above at the moment.
