From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 Oct 2009 05:36:22 +0000
Subject: Re: [PATCH 0/4][RFC]: coding convention for CCID-struct prefixes
Message-Id: <20091006053622.GA3585@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > I am waiting for the feedback also in order to rebuild the test tree; and have
| > informed CCID-4 developers (CCID-4 subtree) about this.
| 
| On a first look I saw one inconsistency, while in ccid3 you do:
| 
| -	return scaled_div(w_init << 6, hctx->tx_rtt);
| +	return scaled_div(w_init << 6, hc->tx_rtt);
| 
| in ccid2 you do:
| 
| -	struct ccid2_seq *seqp = hctx->ccid2hctx_seqh;
| +	struct ccid2_seq *seqp = hctx->tx_seqh;
| 
| Since this change is about reducing the names by removing redundancy, I
| think the ccid3 variant is better, i.e.: hc->tx_foo.
| 
I fully agree with your comment, but could I ask you to take a second look please?

(My fine-grained separation of patches may not have been as good an idea
 as I had initially thought.)

The first change (scaled_div/ccid3) is from patch 1/4, whereas the second (seqp/ccid2)
is from patch 4/4. In the end the changes complement one another, and both ccids have
the same naming scheme:
 * patch 1/4 replaces hc{tx,rx}->ccid2hc{tx,rx}_ with hc{tx,rx}->{tx,rx}_ (ccid2.{c,h})
 * patch 2/4 replaces hc{tx,rx}->ccid3hc{tx,rx}_ with hc{tx,rx}->{tx_rx}_ (ccid3.{c,h})
 * patch 3/4 replaces hc{tx,rx}->{tx,rx}_ with hc->{tx,rx}_ (ccid2.{c,h})
 * patch 4/4 replaces hc{tx,rx}->{tx,rx}_ with hc->{tx,rx}_ (ccid3.{c,h})

I checked again and re-applied the submitted patches and did the following:

gerrit@virtual_carrot > grep -REhC2 'hc(tx|rx)' net/dccp/
static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
{
        struct ccid3_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
        BUG_ON(hctx = NULL);
        return hctx;
}

--
static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
{
        struct ccid3_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
        BUG_ON(hcrx = NULL);
        return hcrx;
}

These are the only two exceptions, I left the hc{tx,rx} in since they don't appear
in a prefix. 

Can you please have a look and say whether you are ok with the naming scheme?

As per earlier email, I'd be ok to repackage or combine the patches into a single one,
or combine patch 1/4 with 3/4 and 2/4 with 4/4.
