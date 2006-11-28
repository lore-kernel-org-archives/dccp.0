From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 14:30:01 +0000
Subject: [PATCH 0/2] [RFC]: Clean-ups
Message-Id: <200611281430.01278@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  most things merged, except for the packet size and
|  TRFC equation patches, that I thought a day or two would be nice for
|  further discussion.

I have tidied up what remained and uploaded the up-to-date remaining patches on to
     http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/


There are two small patches which I send as RFC, for the first I need a consensus:

Patch 1: Removes a typo in setting the nofeedback timer. 
         => Question: The nofeedback timer is currently set to time out after

                           max(t_rto, 2 * s/X)  =  max(max(4*R, 1 second), 2 *s/X)

                       This is non-standard and has been flagged in the code as such
             I have conferred with a colleague who does a lot of simulations in this
             field and he says doing this is bad, especially when the RTTs are small.
             Therefore, since it is both non-standard and obviously not a good idea,
             I want to suggest revising the entire patch so that the nofeedback timer
             expires after max(4*R, 2 * s/X) as per RFC 3448.
             OK with this suggestion?

Patch 2: Implements a useful idea which Ian suggested while discussing one of the
         previous patches: if the `len' arguments of ccid_{send_packet,packet_sent}()
         are unsigned, then we do not need to perform extra checks against `len > 0'
         The patch implements this idea and, as a result, another unused block/test
         in ccid3.c can go.

Gerrit
