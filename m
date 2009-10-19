From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 19 Oct 2009 05:24:24 +0000
Subject: Re: [PATCH 3/4] Implement dropped packets option
Message-Id: <20091019052424.GD3366@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B80D.8090207@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B80D.8090207@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| +static struct tfrc_tx_hist_entry*
| +	tfrc_sp_seek_tx_entry(struct tfrc_tx_hist_entry *head,
| +			      u64 seqno, u32 backward)
| +{
| +	if (head = NULL)
| +		return NULL;
| +
| +	while (head->seqno != seqno) {
| +		head = head->next;
| +
| +		if (head = NULL)
| +			return NULL;
| +	}
| +
| +	while (backward-- > 0) {
| +		head = head->next;
| +
| +		if (head = NULL)
| +			return NULL;
| +	}
| +
| +	return head;
| +}
| +
| +/*
| + * tfrc_sp_p_from_loss_intervals_opt  -  calcs p from loss interval option
| + * li_data:		data parsed from options
| + * head:		contains ccval info
| + * curr_ccval:		current ccval
| + * seqno:		last acked seqno
| + */
| +u32 tfrc_sp_p_from_loss_intervals_opt(struct tfrc_tx_li_data *li_data,
| +				      struct tfrc_tx_hist_entry *head,
| +				      u8 curr_ccval, u64 seqno)
| +{
<snip>
| +
| +	for (i = 1; i <= k; i++) {
| +		i_i = li_data->loss_interval_data[i];
| +		i_totl += i_i;
| +		ccval = tfrc_sp_seek_tx_entry(head, seqno, i_totl - 1)->ccval;

tfrc_sp_seek_tx_entry() can return NULL (as per above implementation). Then this
will crash/panic.

<snip>
| +
| +		if (i > 1)
| +			i_tot1 += i_i * tfrc_lh_weights[i-2];
| +	}
| +
| +	ccval = tfrc_sp_seek_tx_entry(head, seqno,
| +			li_data->loss_interval_data[1] - 1)->ccval;
Here it can also crash.

Getting a sender-based implementation right is complex, since it requires to
enforce consistency and garbage collection for so many data structures.

That is why I think it would be easier to start with a receiver-based implementation
and then grow it into a sender-based implementation if it shows promise.
