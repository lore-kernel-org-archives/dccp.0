From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 05 Jan 2007 00:34:20 +0000
Subject: Re: [dccp] Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <459D9D0C.5010503@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> Also, the weights in dccp_li_hist_w appear to be wrong.  They should 
>> be 5, 5,
>> 5, 5, 4, 3, 2, 1, not 4,4,4,4,3,2,1,1, according to rfc3448.
>>
> I don't believe so. We've done this as per section 8 of RFC3448 and
> divide by 4 rather than 5.
> 

Ah yes, never mind.
Eddie
