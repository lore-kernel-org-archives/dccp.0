From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 09 Jun 2007 18:56:13 +0000
Subject: [PATCH 0/6]: RTT Estimation and Packet Scheduling
Message-Id: <200706091956.13551@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

With the exception of patch #1, all patches in this changeset
are concerned with RTT estimation.

Patch #1: Avoids the accumulation of large send credit. This patch
          has been discussed for a while. It is not yet clear whether
          the upper bound should be one t_ipi or one RTT. This patch
          uses t_ipi as a safe and conservative bound. This could be
          changed later, but without a bound it will clearly happen 
          that large send credits will build up which will cause bursty
          traffic over a disproportionally long time.

Patch #2: Sin of omission fixed - we didn't use a fallback RTT as per RFC 4340.

Patch #3: Stops CCID3 sending trivial amounts of elapsed time. I found this out
          while reverting the interface timestamp patches submitted in April. 
          The point is that with the window counter CCVal as RTT indicator and
          the CCID3-specific feedback mechanism, the elapsed time will amount
          to tiny amounts of time between calling the send routine, since feedback
          is sent immediately: this amounts to elapsed time in the order of < 50 usec.

Patch #4: The interface of dccp_sample_rtt is relieved of some of its burden.

Patch #5: More accurate detection of idle times (I think this comes closer to CCID3 now).

Patch #6: Inline for moving average - thanks to Arnaldo.

