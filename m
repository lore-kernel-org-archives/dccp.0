From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Jan 2007 15:40:39 +0000
Subject: [PATCH 0/7]: Use RTT of SYN exchange & Patchv2
Message-Id: <200701231540.39765@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is 
  * one revised re-sent (Patch 1)
  * a larger patch split into six (to make review easier), implementing the use of SYN-exchange RTT
    sample to boost the performance of CCID 3. It is kept generic, so that it could be reused later.

I have compiled on x86, SMP and sparc64 and tested on x86. The performance was pretty good, suddenly
in later stages the dccp_probe results were quieter (still oscillating during slow-start). 

Patch 1: Is Patchv2 for 
         http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/4e_suseconds_t_64-bit-warning.diff
         I have removed the `unsigned' casts. Thanks Ian.

Patch 2: Provides a new function rfc3390_initial_rate() for the initial sending rate.

Patch 3: Idle and application limited periods: this correctly implements [RFC 4342, 5.1] in that
         the sending rate shall not be reduced below the rfc3390_initial_rate() in an idle period.

Patch 4: DCCP library function for sampling RTTs from packet exchanges.
         RTTs are actually sampled quite often in the DCCP code, and so providing a function for this
         purpose makes sense (it is applied a patch below). 

Patch 5: This applies the new function, dccp_sample_rtt(), to replace existing uses.

Patch 6: Sampling RTT from SYN (initial Request/Response) exchange. This implements the recommendation
         in the erratum to RFC 4342 and in draft-ietf-dccp-rfc3448bis. The sampling works by adding a
         timestamp option to the open()ing Request, and catching timestamp echo option on the matching
         Response. The result is obtained via dccp_sample_rtt() and stored in dccp_sock() so that CCIDs
         can use it. No extra field required for this, due to exploiting an existing / unused field of
         dccp_sock via alias.

Patch 7: Implements the use of SYN-exchange RTT for CCID 3, using the mechanism defined in rfc3448bis.


The lot has been uploaded  to http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog
