From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 02 Aug 2007 14:46:19 +0000
Subject: [PATCH 0/2]: Typo and RFC for CCID2
Message-Id: <200708021546.19513@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is one minor patch and an RFC:

Patch #1: Typo in documentation, also clarified whether receiver
          coverage is inherited (question read in VLC sources).

Patch #2: This is not in the test tree yet, I am sending that
          for discussion / approval. I have dropped the `always support
          Ack Vectors' patch upon Arnaldo's suggestion that keeping it
          can be a useful aid in debugging.
 
          This patch fixes a different problem: when both CCIDs are disabled
          (stupid, but possible combination) then DCCP will not work, the
          call to socket() will return with -ENOMEM, due to allocation in
          dccp_init_sock(). The suggestion is to always build CCID2, since
          it is also set as DCCPF_INITIAL_CCID in linux/dccp.h
          I am asking whether people are ok with this and how the Kconfig
          `debug output' options should be kept.
