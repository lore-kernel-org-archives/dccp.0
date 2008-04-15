From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 15 Apr 2008 07:13:37 +0000
Subject: Re: location of ccid4 source-code ?
Message-Id: <20080415071337.GB8029@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804151708.22797.golam.sarwar@nicta.com.au>
In-Reply-To: <200804151708.22797.golam.sarwar@nicta.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| I've pulled the latest sources from :: git://eden-feed.erg.abdn.ac.uk/dccp_exp
| It's doesn't have ccid4 sources in it. I was wondering is there's any other 
| place where ccid4 sources/patches are kept ?
| 
No, it is the same tree, you just need to pull the `ccid4' subtree
rather than the `dccp' subtree:

	1. checkout a local branch, e.g. ccid4_local

		git checkout -b ccid4_local master

	2. pull the subtree into this branch

		git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp  +ccid4:ccid4_local


Since it is a subtree, it automatically also has the test tree included.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

