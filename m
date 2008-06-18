From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 18 Jun 2008 08:16:57 +0000
Subject: Re: QUESTION : Feature length about the non-negotiable feature
Message-Id: <20080618081657.GA23684@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <48579530.4010807@cn.fujitsu.com>
In-Reply-To: <48579530.4010807@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> Implementing this option as variable length is not RFC compliant.  If you
> would like to be forwarded the discussion about fixed vs. variable length
> -- the option was originally variable length -- please let me know.

Yes, it would be good to forward this as input. I found three problems
with using fixed-length (as opposed to variable-length) NN-options:

 (1) Non-negotiable options are much more part of the traffic than some
     server-priority options such as e.g. the CCID or Allow Short Seqnos:
     - Sequence Window should be set as the connection progresses (7.5.2);
     - Ack Ratio is updated for each congestion window (RFC 4341, 6.1.2).

 (2) Increased overhead
     The feature default values of Ack Ratio (2) and Sequence Window (100)
     both fit into one byte. For small Sequence Windows, using a fixed-size
     option incurs an overhead of unused header space up to 5 bytes. For
     Ack Ratio this is less (1 byte), but the overheads accumulate on a global
     basis when the sizesare subtracted from the MPS.

 (3) Consistency with other uses of header options
     (a) NDP Count
         The NDP Count option is variable-length (1..6 bytes), RFC 4340, 7.7
	 encourages to use the smallest container format.

     (b) Timestamp Echo Option
         When the Elapsed Time area of the Timestamp Echo Option is used,
	 section 13.3 encourages to use the smallest variant of the option
	 that can hold the relevant Elapsed Time value.

From what I can see, fixed lengths for NN options are mentioned in
sections 6.5, 6.6.8, 7.5.2, and 11.3.
