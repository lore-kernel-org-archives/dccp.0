From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Feb 2011 11:32:44 +0000
Subject: Re: [PATCH 0/4]  dccp: Congestion Window > Sequence Window
Message-Id: <20110222113244.GA3962@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1297647741.9816.143.camel@jero-laptop>
In-Reply-To: <1297647741.9816.143.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| The second patch fixes an issue in the feature negotiation code where
| Confirm options are retransmitted forever.
| 
| The third patch fixes an issue in the feature negotiation code where
| DCCP would reset the connection on a Confirm for a value of an NN option
| other than the most recent. The RFCs imply that such an option should
| just be ignored. Further, this causes a connection reset if the value of
| an NN option changes twice in under two RTTs.
| 
Thank you for sharing theise. I would like to work on putting them into the
test tree by the begin of next week, am backlogged until the end of this one.

The only patch that has an issue is #2: this reintroduces a problem which
occurred earlier when performing feature negotiation during the initial
handshake. Since your patch set targets feature negotiation in established
state, there should be a way to enable both - i.e. keep the old behaviour
for the initial, and use the new one for the established state.

Other issues that would be good to resolve before uploading the patches:
 * some have minor codingstyle issues, I am ok to fix stuff up to some
   degree; but please consider scripts/checkpatch.pl
 * could you add comments (short descriptions) about conditions you observed,
   or add pointers to documentation webpages in the commit message? It helps
   in future discussions to come back on track faster.
