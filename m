From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Sep 2007 10:00:11 +0000
Subject: Re: CONFLICT using git-pull
Message-Id: <200709191100.11486@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
In-Reply-To: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Leandro, -

|  But when I type git-pull
Warning: I don't know your configuration, but if you are checking out everything
(which is fine), you will get the most recent netdev-tree. This is currently
tracking davem-2.6.git (not davem-2.6.24.git, due to the troubles reported earlier).

The first thing I'd ask you to try is to check out _only_ the DCCP tree:

 1. use your normal tree
 2. create a subtree dccp:

	git branch -b dccp master

 3. now pull the `dccp' subtree into your tree (as Ian also recommended)

	 git-pull git://eden-feed.erg.abdn.ac.uk/dccp_exp dccp

If this still fails then there is a difference between your tree and the netdev-2.6 one
which needs to be resolved.

For such cases, I put up extracts from the DCCP patches online at 

	http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/

HTH
Gerrit
