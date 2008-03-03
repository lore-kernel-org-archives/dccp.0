From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 03 Mar 2008 07:34:54 +0000
Subject: Re: [DCCP] [RFC]: Getting rid of unwieldy struct prefixes
Message-Id: <20080303073454.GA6937@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080229094518.GA12858@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > [CCID-2]: Get rid of ccid2hc{tx,rx}_ prefixes
<snip>
| I haven't checked, is this over what is now on the test tree or on
| upstream?
| 
The patch applies on top of the test tree (now online again), i.e. it 
should apply when checking out a separate branch with the test tree in it.

Are you basically ok with the naming scheme, do you have other
suggestions or are there additional considerations?
