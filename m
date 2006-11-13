From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Nov 2006 13:27:24 +0000
Subject: [PATCH 0/7]: Retransmission & Sequence Numbers
Message-Id: <200611131327.24492@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is one medium-sized patch (20k), 
split into 7 piecemeal chunks.

Patch 1:  Update comments on precisely which packets can be retransmitted
          Program documentation

Patch 2:  Increment sequence numbers on retransmitted Response packets
          As per http://www.mail-archive.com/dccp@vger.kernel.org/msg00659.html

Patch 3:  Add sysctls to control retransmission behaviour
          
Patch 4:  Introduce a consistent naming scheme for sysctls
          As in TCP, DCCP sysctls have all been prefixed with sysctl_dccp_xxx.

Patch 5:  Remove forward declarations in timer.c
          Another few forward declarations erased.

Patch 6:  Remove redundant statements in init_sequence (ISS) 
          Removes dead code - a similar patch has been accepted for TCP.

Patch 7:  Choose a real initial sequence number
          Is a DCCPv6 fix: so far, no ISS was chosen.

I have uploaded these as series `11' (1..7 map to a..f) onto 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/

Ian what about your memsysctl patches - it would be useful to have them
and I could change patch 3/4 to match that, but they have not been submitted yet.

-- Gerrit
         
