From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Aug 2007 23:13:04 +0000
Subject: [PATCH 0/6] DCCP: Implement TFRC Faster Restart
Message-Id: <200708291113.07431.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch set implements TFRC Faster Restart as per current draft.

Patche can also be found at:
http://wand.net.nz/~iam4/dccp/patches24/
(although do not apply patch 7)

The faster restart implementation was based on 
draft-ietf-dccp-tfrc-faster-restart-03.txt.

The version of DCCP CCID3 in Gerrit's tree used as the base is (mostly) 
draft-floyd-rfc3448bis-00.txt where the faster restart Internet Draft 
specifies the use of draft-ietf-dccp-rfc3448bis-02.txt.

We did not implement all of the Internet Draft for faster restart as it was 
either not required, or the base DCCP did not support the features required.

In particular the following features are missing:

    * keep alive pings as per section 3.1. It has been proposed at IETF 69 to 
remove these.
    * the use of X_recv_set as per section 3.2. We use X_recv instead as 
X_recv_set is not part of rfc3448bis-00.txt
    * Interpolation of X_fast_max as per section 3.2. This is used for idle 
periods to scale back the faster restart and is used for idle periods in 
minutes. As our tests are shorter than this in duration we have not 
implemented. We have however provided the framework for this so it would be 
trivial to complete this if desired.
    * the measurement of the receive rate in the last RTT as per section 4.2. 
We have left our implementation at the receive rate since last feedback sent 
for simplicity of implementation. We do not believe that this would have a 
material affect, and it would equally affect both the standard implementation 
and faster restart so it would be cancelled out.
