From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 30 Nov 2007 12:19:36 +0000
Subject: Re: [RFC]: tfrc_tx_hist_rtt
Message-Id: <20071130121936.GC28277@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071129172954.GL12069@ghostprotocols.net>
In-Reply-To: <20071129172954.GL12069@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sorry I only got this email today and it is a busy day, too.

The changes look good and are in general a further improvement on the
code. I like the idea of hiding the internals of the list structure in 
the source file.

I wonder if one could go one step further and also take the timestamp
directly when looking up the previous history sample, e.g.

	u32 tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head, const u64 seqno)
	{
		u32 rtt = 0;
		struct tfrc_tx_hist_entry *packet = tfrc_tx_hist_find_entry(head, seqno);
	
		if (packet != NULL) {
			rtt = ktime_us_delta(ktime_get_real(), packet->stamp);
			/*
			 * Garbage-collect older (irrelevant) entries:
			 */
			tfrc_tx_hist_purge(&packet->next);
		}
	
		return rtt;
	}

Just a suggestion.

Thanks for looking through this.
