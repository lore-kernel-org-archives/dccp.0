From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 17 Jul 2007 14:38:15 +0000
Subject: Re: TFRC Faster Restart implementation for Linux DCCP
Message-Id: <200707171538.15195@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
In-Reply-To: <5640c7e00707152131k689ff53dn105ed1c0f3b90717@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Given how TCP handle extensions I think the
|  best way for this is a sysctl as can turn it on or off system wide.
|  The default, initially, should be off. The other alternative is to
|  enable it via a socket option as TCP Nagle does.
Could use a module parameter to the CCID3 module to enable it.

|  
|  I will be using your git-tree as my development base and once I get it
|  coded I'd be greatly pleased if you can put it in the tree somehow.
Yes sure - that is what the tree is there for.
