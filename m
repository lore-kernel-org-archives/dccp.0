From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 18:30:31 +0000
Subject: Re: [PATCH 1/6]: Fix bug in calculation of first t_nom and first t_ipi
Message-Id: <200611271830.31226@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.07412@strip-the-willow>
In-Reply-To: <200611211545.07412@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  I'm not in favour of being non standard
|  compliant in the CCID3 implementation nor the core, just that I, at
|  least, would love to hear from experimental CCID implementators
|  requirements for the interaction of the standards compliant DCCP core
|  with the experimental CCIDs, i.e. net/dccp/ccids.[ch] basically.
I am also much in favour of this. It is however a different area. That is
why I said I can think of interacting constructively with Eddie's ideas.
This would be something which solves an existing issue, rather than adding
further issues to the existing list.

Gerrit
