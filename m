From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 14 Apr 2008 06:50:41 +0000
Subject: Re: [PATCH 0/5] [DCCP]: Queuing policies
Message-Id: <20080414065041.GA4431@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804111224.06958.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| This is resubmission of queuing policy related patches for DCCP. Queuing 
| policies allow userspace applications to more effectively use DCCP.
Thanks a lot -- all patches applied cleanly. As promised, I have created
a tree "qpolicy" for these patches, which can be checked out via

	# using a recent netdev-2.6 kernel
	git checkout -b qpolicy master
	git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp  qpolicy

I have left your patches unchanged (apart from adapting them to apply
on the most recent base). 

There are four other patches in this repository: I am interested in merging
your patches into the test tree and thus have worked on integrating it.

Rather than sending those new 4 patches individually, I will send the result
(combined with your patch set) as a single RFC patch to the list.

Please have a look at the repository and the subsequent patch -- I would
like to know if you are ok with the changes and/or discuss these.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

