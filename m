From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Jun 2007 08:40:22 +0000
Subject: Re: [Announce]: How to access Experimental Test Tree
Message-Id: <200706250940.22801@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706221523.29662@strip-the-willow>
In-Reply-To: <200706221523.29662@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Thanks for these instructions. Very helpful. Unfortunately the
|  alternative way didn't work for me but the others did just fine.

Thanks very much for the testing (see other email), this is much appreciated.

I am not entirely sure about the alternative way either, but it worked once with
git version 1.5.2.2.238. For simplicity, the two-step approach (fork and then pull)
seems best and works reasonably fast.


|  > Even better: only pull the relevant `dccp' subtree:
|  > ---------------------------------------------------
|  > 1. The experimental tree is updated every work day from David Miller's tree
|  >    it is a good idea to take an up-to-date copy first:
|  >
|  >       git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6
|  >
|  > 2. chdir into your up-to-date git repository
|  >
|  > 3. create a subtree `dccp' using the commands
|  >       git checkout -b dccp master
|  >
|  > 4. pull the experimental DCCP tree into this branch using
|  >       git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp.git dccp
