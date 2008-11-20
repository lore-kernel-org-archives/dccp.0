From: David Miller <davem@davemloft.net>
Date: Thu, 20 Nov 2008 09:03:21 +0000
Subject: Re: [PATCH 1/5] dccp: Mechanism to resolve CCID dependencies
Message-Id: <20081120.010321.191266507.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 18 Nov 2008 06:03:47 +0100

> | > +	list_for_each_entry(entry, fn_list, node)
> | > +		if (entry->feat_num = feat_num && entry->is_local = is_local)
> | > +			return entry;
> | > +		else if (entry->feat_num > feat_num)
> | > +			break;
> | 
> | Personally, I would have put braces around this basic block.
> | 
> If it is possible to modify without disturbance, I attach a patch for this and
> have changed it in the test tree.
> 
> I have checked that making this change does not affect subsequent
> patches - it works with either variant.

Applied, thanks Gerrit.  Please give a signoff next time.
