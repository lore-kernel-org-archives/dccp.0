From: David Miller <davem@davemloft.net>
Date: Mon, 10 Nov 2008 21:16:03 +0000
Subject: Re: [PATCH 2/4] dccp: Registration routines for changing feature
Message-Id: <20081110.131603.182636098.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1225950014-6337-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1225950014-6337-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu,  6 Nov 2008 06:40:12 +0100

> Two registration routines, for SP and NN features, are provided by this patch,
> replacing a previous routine which was used for both feature types.
> 
> These are internal-only routines and therefore start with `__feat_register'.
> 
> It further exports the known limits of Sequence Window and Ack Ratio as symbolic
> constants.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Applied.
