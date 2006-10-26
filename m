From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 26 Oct 2006 13:36:04 +0000
Subject: Re: [PATCH 0/17] [DCCP]: patch-backlog, bug-fixes, some code simplifications
Message-Id: <200610261436.05041@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200610241458.51517@strip-the-willow>
In-Reply-To: <200610241458.51517@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

To make good on the claim that the backlog is exhaustive, I have gone through 
the past postings and can only identify the following, i.e. a single really
outstanding patch under (3):

1) Patches which seem to be experimental:
-----------------------------------------
	* Experimental support for tcp_congestion_ops: 
          http://www.mail-archive.com/dccp@vger.kernel.org/msg00425.html
	* CCID 2 profiling
	  http://www.mail-archive.com/dccp@vger.kernel.org/msg00375.html
	* Shift constants into header
	  http://www.mail-archive.com/dccp@vger.kernel.org/msg00520.html

2) Patches which have been withdrawn:
-------------------------------------
	* Always log debug messages when CONFIG_DEBUG is set
	  http://www.mail-archive.com/dccp@vger.kernel.org/msg00580.html
           -- this was an RFC version, please do not regard 
	* Remove socket option / fix setting of packet size in CCID3 / 2 new sockopts [5..7/7]
		http://www.mail-archive.com/dccp@vger.kernel.org/msg00521.html
		http://www.mail-archive.com/dccp@vger.kernel.org/msg00522.html
		http://www.mail-archive.com/dccp@vger.kernel.org/msg00523.html
	   -- merge request was withdrawn on 
	      http://www.mail-archive.com/dccp@vger.kernel.org/msg00591.html
 	   -- a strategy was discussed on
 	      http://www.mail-archive.com/dccp@vger.kernel.org/msg00581.html
              ... but no time so far to get down to the code !

3) Patches that are outstanding and have not been archived in the backlog:
--------------------------------------------------------------------------
 	* DCCP conntrack/NAT on 
          http://www.mail-archive.com/dccp@vger.kernel.org/msg00108.html
	

If anything has been omitted despite quite thorough efforts, please notify.


When new stuff gets posted, I will put it up on http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/ ;
when a patch is removed via discussion, it will likewise be removed from there. All subsequent patches
will be on top of the last one in the archive. 


Gerrit
