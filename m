From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:57:39 +0000
Subject: [PATCH 0/4]: Minor changes & documentation
Message-Id: <200701031357.39809@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here are a few `easy' patches in between.

Patch 1: Simplifies the macro used for DCCP debug messages
         (debugging is no longer automatically on for static builds, uses
          kernel commandline instead)
 
Patch 2: More debug information for dccp_wait_for_ccid
         I have found this very useful when debugging error cases. (With
         Arnaldo's ctracer, it seems there is now less need for this :-)
         In particular: the `delayed by' statement is helpful and catches 
         an earlier statement used by Ian in ccid3_hc_tx_send_packet.
         

Patch 3: Add missing documentation for CCID 3 socket options

Patch 4: More output in dccp_probe
         dccp_probe is such a nice tool that I think it makes sense to add
         a few more fields. I have added a few scripwhich can be downloaded 
         from:
  		http://139.133.210.30/users/gerrit/dccp/dccp_probe/
	 
	 Example output is on
		http://139.133.210.30/users/gerrit/dccp/dccp_probe/examples/

	 (I have an explanation why the plots come this way, this follows later).

