From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 03 Dec 2007 14:08:29 +0000
Subject: Re: [Announce]: Test tree up{dated,loaded}
Message-Id: <20071203140829.GF18547@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071203084106.GB5484@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071203084106.GB5484@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Leandro, -

| Hi Gerrit,
|   thank you for the announcement. I'm using the ccid4 branch and I
| suppose that Tommi is also using the tree. I plan to submit new
| patches for these days...
| 
I'd be grateful if you could have a look at the CCID4 tree. I ported
these changes late last night; the update to 2.6.25 had taken most
of the weekend. It compiled cleanly (apart from the warning message
that tfrc_state_names are unused, which happens when CCID4_DEBUG is
not set), but in case I may have overlooked something it would be
good to cross-check.

Best regards
Gerrit
