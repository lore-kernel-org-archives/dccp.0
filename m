From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Sep 2007 14:32:40 +0000
Subject: [PATCH 0/5]: Misc Bugfixes
Message-Id: <200709121532.41129@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

While working on something else in DCCP, I noted several bugs, most
of these introduced by me. The present patch set fixes these.

Patch #1: Fixes sequence number wrap-around problems.

Patch #2: Fixes overwriting of Reset codes in dccp_v{4,6}_conn_request

Patch #3: Updates Ack Vector / Elapsed Time processing wrt RFC 4340.

Patch #4: Maps the PASSIVE_1 auxiliary state onto TCP_CLOSE_WAIT, since
          otherwise inet_accept will complain.

Patch #5: A fix for the Request/Response RTT sampling: I forgot that option
          processing can take time, which got factored into the RTT value
          (see patch for full details). Fixed by taking the timestamp earlier
          (but not at the interface :).
          Arnaldo, I would like to submit this one with regard to 2.6.24 and
          to make things simpler I would like to merge this update with the
          earlier patch - I hope that this is ok - will put it into the test tree.
