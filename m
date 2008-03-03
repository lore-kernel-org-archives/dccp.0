From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 03 Mar 2008 13:57:46 +0000
Subject: Re: [DCCP] [RFC]: Getting rid of unwieldy struct prefixes
Message-Id: <20080303135745.GA15241@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | > [CCID-2]: Get rid of ccid2hc{tx,rx}_ prefixes
<snip>
| > Are you basically ok with the naming scheme, do you have other
| > suggestions or are there additional considerations?
| 
| Its ok, everywhere we use hctx or hcrx as the variable name, so its ok
| for plain old grep to find it.
| 
Great, thanks for checking this. It makes the code much clearer.

Will check this RFC patch once again and upload it, doing a similar 
update for CCID-3/-4 is further work.

Cheers
Gerrit
