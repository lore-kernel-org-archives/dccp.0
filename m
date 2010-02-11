From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 11 Feb 2010 06:26:17 +0000
Subject: net-2.6 [PATCH 0/2] udp/dccp: MSG_TRUNC
Message-Id: <1265869579-5829-1-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Dave,

I have here two datagram-API patches, both submitted for net-2.6:

Patch #1: Resolves missing MSG_TRUNC support. Since DCCP is datagram-based,
          the user-space API is broken/incomplete without.

Patch #2: UDP recvmsg() cleanup, remove redundant variable. 	  
