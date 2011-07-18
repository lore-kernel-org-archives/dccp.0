From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 18 Jul 2011 00:11:40 +0000
Subject: Re: [PATCH 02/07] dccp: support for exchanging of NN options in
Message-Id: <20110718001140.GA3767@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1310650955-5159-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1310650955-5159-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > +	/*
| > +	 *	Support for exchanging NN options on an established connection
| > +	 *	This is currently restricted to Ack Ratio (RFC 4341, 6.1.2)
| > +	 */
| 
| This comment is out of date. We now process Sequence Window updates
| dynamically. I would remove the second line.

Good catch. I am actually glad it is no longer true, thanks to your work we
have now full NN support in DCCP. Have removed it.
