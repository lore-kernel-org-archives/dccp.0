From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 22 Sep 2006 16:57:57 +0000
Subject: Re: [PATCH 6/7] [DCCP]: Fix setting of packet size in CCID3
Message-Id: <45141615.30908@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200609221432.20022.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221432.20022.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> |  +	case DCCP_SOCKOPT_TX_PACKET_SIZE:
> |  +		if (dmsk->dccpms_tx_ccid != DCCPC_CCID3)
> |  +			err = -EINVAL;
> This is unfortunate: it is in the generic dccp code but
> works only for CCID 3. Same for DCCP_SOCKOPT_RX_PACKET_SIZE.

I agree with Gerrit.  An average packet size congestion control parameter 
might be useful for multiple CCIDs, even if only some CCIDs would use it. 
Would prefer that this sets the parameter in all cases.

E

> 
> 
> --Gerrit
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
