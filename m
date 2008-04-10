From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 10 Apr 2008 07:26:02 +0000
Subject: Re: [DCCP]: Make queuing policy an attribute of a socket
Message-Id: <20080410072602.GA10419@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.39460.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > But it is not really a problem. The above section is within the #ifdef
| > __KERNEL__ so afaik is not visible to userland. So, yes, option (b) is
| > the only alternative - maybe Arnaldo has a better suggestion.
| >
| Right. But then if struct dccp_sock is neither visible from userland, nor is 
| it used in any other part of the kernel then why not move it to 
| net/dccp/dccp.h?
| -- 
This is something I don't understand myself and thus asked Arnaldo if
there is a reason/alternative for it.

Basically I can't see why this shouldn't be possible. SCTP for example
defines its struct sctp_sock in <net/sctp/structs.h>. But for the "older"
protocols like TCP and UDP (including UDP-Lite), the struct xxx_sock is
declared in include/linux/{tcp,udp}.h.

I think there is potential for a clean-up:
 -- with the recent updates of CCID-3/4, the header file <linux/tfrc.h>
    has had its role changed (it now only serves to export the structs
    visible via CCID-3/4 getsockopt)
 -- in net/dccp there are 5 header files (not counting qpolicy.h), 
 -- in net/dccp/ccids there are another 2 (3 with CCID-4) header files
 -- in net/dccp/ccids/lib there are another 3 header files

This gives a total of 10 header files underneath net/dccp and two header
files (<linux/tfrc.h> and <linux/dccp.h>) under include/linux.

Maybe this could benefit from concentrating the header files in a
directory include/net/dccp as SCTP does (which incidentally also has
12 header files there).		


The University of Aberdeen is a charity registered in Scotland, No SC013683.

