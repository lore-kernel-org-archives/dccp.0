From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Apr 2008 09:51:34 +0000
Subject: Re: [DCCP]: Start implementation of queuing policies
Message-Id: <20080407095134.GL6146@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.33309.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.33309.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| One short notice: not all concepts which we were discussing with Gerrit were 
| implemented in those 5 patches (constructors, destructors, per policy 
| sockopts). But I think this patch series is complete enough to be useful.
| -- 
It is. I have started to set up a tree for it, but then ran into
problems since the coding style differed in several cases from kernel
coding style and it was not easy to fix this since then the subsequent
patches failed to apply.

When you submit patches, can you please take the following into account

 * check with regard to CodingStyle - I have added a few comments, often
   scripts/checkpatch.pl can point out where it does not fit;

 * please copy to both dccp@vger.kernel.org and netdev@vger.kernel.org -
   it is a request by Arnaldo at the end of last year and helps to find
   problems earlier;

 * as per Ian's comment, please put the patches into the body of the email,
   this makes it easier for others to look at them (one caveat to consider
   is that most GUI clients mangle tabs into spaces and try to break
   lines for text wrapping; both needs to be disabled);

 * it would be great to have numbering in subsequent patches.

Please let me know if you intend to resubmit these patches, I have
currently little time and am unable to fix the CodingStyle problems,
would otherwise be willing to put up the repository quite soon.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

