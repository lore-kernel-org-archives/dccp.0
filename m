From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 05 Oct 2009 12:38:23 +0000
Subject: Re: [PATCH 0/4][RFC]: coding convention for CCID-struct prefixes
Message-Id: <20091005123823.GE30535@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Oct 05, 2009 at 01:23:59PM +0200, Gerrit Renker escreveu:
> | After Arnaldo takes a look, I can add this as-is to net-next-2.6
> This should work, they have been compile/sparse-tested and apply cleanly on net-2.6.
> 
> I am waiting for the feedback also in order to rebuild the test tree; and have
> informed CCID-4 developers (CCID-4 subtree) about this.

On a first look I saw one inconsistency, while in ccid3 you do:

-	return scaled_div(w_init << 6, hctx->tx_rtt);
+	return scaled_div(w_init << 6, hc->tx_rtt);

in ccid2 you do:

-	struct ccid2_seq *seqp = hctx->ccid2hctx_seqh;
+	struct ccid2_seq *seqp = hctx->tx_seqh;

Since this change is about reducing the names by removing redundancy, I
think the ccid3 variant is better, i.e.: hc->tx_foo.

- Arnaldo
