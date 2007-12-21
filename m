From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 21 Dec 2007 08:57:17 +0000
Subject: Re: [PATCH 1/8] Remove unnecessary comments to ccids code
Message-Id: <20071221085717.GC4393@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200712201358.43034.leandroal@gmail.com>
In-Reply-To: <200712201358.43034.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Leandro:
| [CCIDS] Remove unnecessary comments to ccids code
| 
| This patch removes some unnecessary files header comments. This was suggested by Arnaldo. According to Arnaldo there is no need to reference the file name in the header comments. It also commit the misspelling of copyright in ccid-4 code, reported by Ian. Note that this patches just apply to ccids code, not for the hole DCCP code.
| 
This patch does not apply on the CCID4 subtree - against which tree are these patches?
In any case, I hope that Arnaldo will consider this for the mainline tree, hence
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
