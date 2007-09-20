From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 20 Sep 2007 13:01:52 +0000
Subject: Re: [PATCH 0/5] CCID 4: initial implementation of CCID 4
Message-Id: <200709201401.52593@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <20070920111557.GA1288@kikai.katei.fi>
In-Reply-To: <20070920111557.GA1288@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Re-submitting, with hopefully proper tags etc.
|  
|  
|  After discussing the topic on IRC, we figured we need a place to have
|  the sources for CCID 4 available for everyone. This way we can finally
|  start cooperating on it.
|  
The patches applied fine, a new subtree `ccid4' has been created to host these.
The subtree can be checked out by

	1) create a subtree

		git-checkout -b ccid4 master

	2) pull the CCID4 subtree 

		pull  eden-feed:/usr/src/GIT/dccp_exp.git ccid4


This tree now sits on top of the test tree, i.e. inherits it. As said, I am ok
tracking changes required to ensure that patches remain applicable. 

What I can't do is to track updates to CCID3 into your code, since that would mean
altering your patches; so it is something you need to keep track of yourselves.

Gerrit
