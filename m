From: David Miller <davem@davemloft.net>
Date: Mon, 05 Oct 2009 10:58:15 +0000
Subject: Re: [PATCH 0/4][RFC]: coding convention for CCID-struct prefixes
Message-Id: <20091005.035815.238234647.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1254739993-5051-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon,  5 Oct 2009 12:53:09 +0200

> this codifies new naming scheme discussed at netconf. Can you please have a
> look and indicate whether you are ok with the set?
> 
> They are divided into 4 for readability, but can be combined into
> one large patch if agreed.

This looks like an improvement to me, I guess.

You can keep it as 4 patches.

After Arnaldo takes a look, I can add this as-is to net-next-2.6
if you like.
