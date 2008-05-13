From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 May 2008 09:37:18 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| 
| > Is there support for this change or are there reasons to keep SOCK_DCCP?
| 
| You'll have to accept it forever since there have been several
| kernel releases already with DCCP support added and there are
| applications out there.
| 
And maybe it is not necessary or worth to change it. 

But there is a problem, the cause is not necessarily the above:

 * using an ai_socktype=0 used to work for DCCP; on dual-stack hosts,
   IPv6 addresses were returned first, so that both IPv6 and IPv4
   clients (v6-mapped-v4) could connect to the server,

 * within the last three months there was a change in the lookup
   behaviour so that now IPv4 addresses are returned first on dual
   stack hosts when AF_UNSPEC is specified with ai_socktype=0,

 * changing preference values in /etc/gai.conf did not help,

 * the only fix was the following (pretend to be UDP):

	if (inSettings->mProtocol = IPPROTO_DCCP)
		hints.ai_socktype = SOCK_DGRAM;

Maybe there is a better fix for this.
