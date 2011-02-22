From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Feb 2011 11:34:13 +0000
Subject: Re: [PATCH 3/4] dccp: Don't Reset On Confirm for Old NN Feature
Message-Id: <20110222113413.GD3962@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1297647936.9816.146.camel@jero-laptop>
In-Reply-To: <1297647936.9816.146.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| --- a/net/dccp/feat.c
| +++ b/net/dccp/feat.c
| @@ -1347,10 +1347,8 @@ static u8 dccp_feat_handle_nn_established(struct sock *sk, u8 mandatory, u8 opt,
|  			return 0;
|  
|  		fval.nn = dccp_decode_value_var(val, len);
| -		if (fval.nn != entry->val.nn) {
| -			DCCP_WARN("Bogus Confirm for non-existing value\n");
| -			goto fast_path_failed;
| -		}
| +		if (fval.nn != entry->val.nn)
| +			return 0;
|  
|  		/* It has been confirmed - so remove the entry */
|  		dccp_feat_list_pop(entry);
| 
This looks good.

It would be good to document this case in a comment above the statement. The description sounds
very plausible and I recall that these warnings were triggered quite often. Returning 0 here 
means that the ChangeL does not enter `confirmed' state, hence gets retransmitted (possibly with
the most recent value).
