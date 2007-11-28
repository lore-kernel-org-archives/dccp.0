From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 28 Nov 2007 08:35:07 +0000
Subject: [PATCH 0/4]: Revised support for passive-close
Message-Id: <11962389111015-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the revised and tested patch for supporting passive-close. Testing
was impaired by a nasty bug (patch #1) which lead to the final Reset not
being sent. Once that had been fixed, things worked out very smoothly.

Other than that I think that the patch set has much benefited from the revision,
all possible combinations of server/client close have been tested, over an
emulated IPv6 satellite link, and with different constellations (client closes
earlier as server and vice versa).

There is one new point, simultaneous-close, that the patch now also deals with.
It is possible (and was observed several times during testing) that client and
server both perform an active-close, in which case both will retransmit their
Close / wait for a Reset ad infinitum. The patch deals with this situation by
letting the client act as tie-breaker here, which was shown to work very satisfactorily:
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/#simultaneous_close

Patch #1: Fixes a bug in the dccp_send_reset() routine: 

Patch #2: Is an updated/revised version of the patch introducing the closing-states.
          Changes:   i) combined with other patch (as suggested by Arnaldo);
	            ii) better/revised documentation;
		   iii) uses the new naming scheme (also thanks to Arnaldo).

Patch #3: Revised and updated patch to support passive-close in terms of state
          transitions. The changes to the previous variant are:
	  * explicit control over transitions into passive-intermediate states;
	  * the leaked-skb issue has been fixed by tracking whether the skb is queued;
	  * support for simultaneous active-close by client and server;
	  * a detailed account of what happens in each state.
	  	
Patch #4: Removes a redundant test (consequence of patch #3).

I have updated the test tree with regard to these patches. Before the end of the
week I will take Arnaldo's changes for 2.6.25, backport them to the mainline basis
that the test tree is based on, and update the test tree with regard to the latest
changes (also updating the subtrees).
