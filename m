From: David Miller <davem@davemloft.net>
Date: Mon, 17 Nov 2008 06:50:40 +0000
Subject: Re: [PATCH 1/5] dccp: Mechanism to resolve CCID dependencies
Message-Id: <20081116.225040.197479116.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 13:11:15 +0100

> This adds a hook to resolve features whose value depends on the choice of
> CCID. It is done at the server since it can only be done after the CCID
> values have been negotiated; i.e. the client will add its CCID preference
> list on the Change options sent in the Request, which will be reconciled
> with the local preference list of the server.
> 
> The concept is documented on
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/\
> 				implementation_notes.html#ccid_dependencies
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.

> +	list_for_each_entry(entry, fn_list, node)
> +		if (entry->feat_num = feat_num && entry->is_local = is_local)
> +			return entry;
> +		else if (entry->feat_num > feat_num)
> +			break;

Personally, I would have put braces around this basic block.
