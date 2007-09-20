From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 20 Sep 2007 15:05:31 +0000
Subject: Ack Vectors, feature negotiation and preview of new patches
Message-Id: <200709201605.31605@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian -

|  > I have just checked and found out that the negotiation of the "Send ack vector feature" is not yet 
|  > implemented. It is not something which can be done with a hack, since the CCIDs can also be negotiated, 
|  > so that enabling Ack Vectors depends on the end result of negotiating the CCID.
|  > I think at the moment we should add this as a ToDo. If I get some time I'll try to implement the
|  > above, but it is more work than anticipated and so depends on available time.
|  >
|  
|  Well I think the discussion is useful as a future reference. There's
|  no hurry on any of this really.

I am happy to announce that feature negotiation now works, which resolves the above problem. Below is
a log dump which shows the successful negotiation of CCID and dependent features during the handshake.
Exchanging NN features during an established connection is also possible (as used e.g. by Ack Ratio for
CCID2). I'll be sending the patches next week after some more testing.

In a nutshell, it works like this:
 * client makes its reservations on the initial Request,
 * server aligns its reservations with the received client reservations, confirms or rejects the NN features
   and has the last word on server-priority (sic!) features,
 * after negotiating the CCID, the server resolves the CCID dependencies:
	- for CCID3 enable Send Loss Event rate, disable Ack Vectors, set Ack Ratio = 0
	- for CCID2 enable mandatory Send Ack Vector, set Ack Ratio = 2 or from sysctl
 * server adds Confirms and local Change options onto Response
 * client performs local checks, adds its Confirms onto the Ack, and enters PARTOPEN; before it does this,
   it enables all successfully negotiated features (or aborts on disagreement)    
 * server receives Ack and enters OPEN; before it does this, it activates all features as the client does

It is now possible to
 * influence negotiation of Sequence Window via feature negotiation
 * negotiate a common minimum Checksum coverage
 * set CCIDs on a per-connection basis via sockopts
 * the above works in general - almost all features use sysctls as default and can be overridden via
   sockopts

I will be sending the patches next week, in small batches, after testing. It is quite a lot since it involved
a few nasty problems which are now resolved. There is some (too much) documentation on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/feature_negotiation/implementation_notes.html

The other news is a patch for wireshark to 
 * decode all feature-negotiation options
 * decode CCID3's X_recv and Loss Event Rate
This is on http://www.erg.abdn.ac.uk/users/gerrit/dccp/apps/wireshark-options-decoding.diff

Here is the log with comments:

# 1. initial startup phase: sequence window needs to be enabled early since needed for AWL/SWL
   -> activating RX Sequence Window, default val0
   -> activating TX Sequence Window, default val0
dccp_feat_finalise_settings: List Dump:
   * local CCID = 2, 3, state=INITIALISING
   * remote CCID = 2, 3, state=INITIALISING
   * local ECN Incapable = 1, state=INITIALISING
   * remote Min. Csum Coverage = 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, state=INITIALISING

# 2. client inserts its options (chose CCID2, note that the server elects to use CCID3 instead)
dccp_feat_insert_opts: Change_R(Min. Csum Coverage, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
dccp_feat_insert_opts: Change_L(ECN Incapable, 1)
dccp_feat_insert_opts: Change_R(CCID, 2, 3)
dccp_feat_insert_opts: Change_L(CCID, 2, 3)
dccp_feat_confirm_recv: Confirm_L(CCID, 3, 3, 2)
dccp_feat_confirm_recv: Confirm_R(CCID, 3, 3, 2)

# 3. client receives Change/Confirms on the server Response
dccp_feat_change_recv: Change_L(ECN Incapable, 1) !
dccp_feat_confirm_recv: Confirm_R(ECN Incapable, 1, 1)
dccp_feat_change_recv: Change_L(Ack Ratio, 0)
dccp_feat_change_recv: Change_R(Send NDP Count, 1) !
dccp_feat_change_recv: Change_L(Send NDP Count, 1)
dccp_feat_confirm_recv: Confirm_L(Min. Csum Coverage, 6, 6, 4, 5, 3, 7, 8, 9, 10, 11, 12, 13, 14, 15)
dccp_feat_change_recv: Change_L(Send Loss Event Rate, 1) !
dccp_feat_change_recv: Change_R(Send Loss Event Rate, 1) !

# 4. client is done (but has not sent the Ack with the Confirms yet)
dccp_feat_activate_values: List Dump:
   * local CCID = 3, 3, state=STABLE
   * remote CCID = 3, 3, state=STABLE
   * local ECN Incapable = 1, state=STABLE
   * remote ECN Incapable = 1, state=STABLE (Confirm pending)
   * remote Ack Ratio = 0, state=STABLE (Confirm pending)
   * local Send NDP Count = 1, state=STABLE (Confirm pending)
   * remote Send NDP Count = 1, state=STABLE (Confirm pending)
   * remote Min. Csum Coverage = 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, state=STABLE
   * remote Send Loss Event Rate = 1, state=STABLE (Confirm pending)
   * local Send Loss Event Rate = 1, state=STABLE (Confirm pending)
   -> activating TX Min. Csum Coverage, val=6
   -> activating RX Min. Csum Coverage, default val=0
   -> activating RX Send NDP Count, val=1
   -> activating TX Send NDP Count, val=1
   -> activating TX Send ACK Vector, default val=0
   -> activating RX Send ACK Vector, default val=0
   -> activating RX Ack Ratio, val=0
   -> activating TX Ack Ratio, default val=2
   -> activating RX Sequence Window, default val0
   -> activating TX Sequence Window, default val0
   -> activating RX CCID, val=3
   -> activating TX CCID, val=3
dccp_feat_activate_values: Activation OK

# 5. this is the Ack sent to the server
dccp_feat_insert_opts: Confirm_L(Send Loss Event Rate, 1)
dccp_feat_insert_opts: Confirm_R(Send Loss Event Rate, 1)
dccp_feat_insert_opts: Confirm_R(Send NDP Count, 1)
dccp_feat_insert_opts: Confirm_L(Send NDP Count, 1)
dccp_feat_insert_opts: Confirm_R(Ack Ratio, 0)
dccp_feat_insert_opts: Confirm_R(ECN Incapable, 1)

# 6. This required the recent patch :)
SYN RTT = 170us
