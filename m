From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 26 Jul 2008 11:22:33 +0000
Subject: [pull-request] [net-2.6 PATCH 0/6] dccp: Revised ICMP / length
Message-Id: <20080726112232.GA5582@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

this is an update on yesterday's submission, which was unnecessarily complex.

I have checked the whole set again and looked through dccp_invalid_packet()
in net/dccp/ipv4.c. There is no need for additional protection: the routine
makes sure that the skb is long enough for the Data Offset (header length),
which is more than the __dccp_basic_hdr_len().      
      
The ICMPv4/6 packet length checks now in effect use the two-stage test you
suggested, to ensure that the ICMP payload is long enough to access the
first 12 bytes that __dccp_basic_hdr_len() dereferences.

Please let me know if individual patches should be resubmitted again.
I have not done this to reduce noise; in any case the changes are also online:
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-2.6.git;a=log

Patch #1: Implements support to distinguish original from retransmitted packets.
Patch #2: Fixes a bug - AWL was never updated. Used by the third patch.
Patch #3: Corrects ICMPv4 sequence number check to use AWL/H instead of SWL/H.
Patch #4: Implements the check from patch #3 for ICMPv6.
Patch #5: Fixes minimum-required length check for ICMPv4 embedded DCCP datagrams
Patch #6: Same as patch #5, but for ICMPv6.


These patches apply to net-2.6 (BUG_TRAP conversion) and can be pulled from

      git://eden-feed.erg.abdn.ac.uk/net-2.6		(subtree `master')

If necessary, I can prepare an upload for net-next-2.6 later.

Gerrit
