From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 26 Jan 2007 03:25:53 +0000
Subject: [PATCH 0/2] DCCP: Improve loss interval handling some more
Message-Id: <200701261625.55721.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

At present we don't track if we lose a burst of packets in a row which means
we get a series of loss intervals with length 1. What this means is that
performance suddenly slumps. Not good. This fix made a big difference for
me - increased performance from 10 Kbits to 200 Kbits on a constrained
1 Mbits link (and then I fixed to higher again later - see my blog).

I've got a fix here for this in a basic form. It doesn't address the
requirement that they be within the same RTT (measured by CCVal) but is
still better than what we have.

I realise that this is slightly different to how Gerrit is tackling as he is
adding CCVal support and looking at using array. Consider this a "March"
patch unless you want to look at sooner. If nothing else it might give ideas
for people on how to do it even better.

Ian
