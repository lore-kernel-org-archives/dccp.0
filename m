From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Nov 2006 13:37:22 +0000
Subject: Re: DCCP CCID 3 bug
Message-Id: <200611301337.22692@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > BTW, I am using CCID3.
|  
|  Ok, now to the next troubleshooting test: can you please try using
|  CCID2? That way we can isolate the problem, is it CCID3 specific?
|  CCID2? Core? Something else?

Yes, please do send all kinds of debug information which you encounter to the list; 
this makes tracking down the errors much simpler. 

Both CCID 2 and CCID 3 now have debugging options, 

 CONFIG_IP_DCCP_CCID2_DEBUG=y
 CONFIG_IP_DCCP_CCID3_DEBUG=y

but in order to get debugging output, these must be explicitly set via module parameter. 
This can be automated. 

If you paste the following into a file /etc/modutils/options,

# options for DCCP
options dccp            dccp_debug=1
options dccp_ccid2      ccid2_debug=1
options dccp_ccid3      ccid3_debug=1
# EOF

and run `update-modules' [alternatively: paste the above at the end of /etc/modules.conf ]

The same options should also be placed into a file /etc/modprobe.d/options (if you are running modprobe);
or alternatively into  /etc/modprobe.conf (man 5 modprobe.conf).

This all is important, much helpful output (e.g. DCCP_BUG(...)) depends on having debugging enabled.

