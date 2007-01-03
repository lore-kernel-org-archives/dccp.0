From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 13:07:56 +0000
Subject: [PATCH 0/5]: Revised older backlog
Message-Id: <200701031307.56132@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a revision of the earliest patches in the backlog,the 
more recent ones will be sent separately. 

Patch 1: Implements (signed) modular 48-bit arithmetic. 
         Now the macros follow the upper-case convention.

Patch 2: Make dccp_delta_seqno return signed numbers - good for code reuse.

Patch 3: Make `before' relation unambiguous - this now mirrors the TCP solution.

Patch 4: Code reuse 1: implement `follows48' on top of dccp_delta_seqno

Patch 5: Implements the INC48() macro I was asking about -- for 48 bit fields where
         dccp_inc_seqno can not be used.
