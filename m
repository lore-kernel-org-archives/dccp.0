From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 17:25:14 +0000
Subject: [PATCH-UPDATE]: Changes after retracting timestamping patches
Message-Id: <200704131825.14989@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Following the earlier discussions of patches, here is the update
after removing the skb_get_timestamp() patches.

I. Changes
=====

The following patches have been withdrawn:

 * 6b_Timestamp_Without-Epoch.diff
        http://www.mail-archive.com/dccp@vger.kernel.org/msg01643.html

 * 6d_CCID3-TX-Use-net_timestamp.diff
        http://www.mail-archive.com/dccp@vger.kernel.org/msg01644.html

 * 6e_CCID3-RX-Use-net_timestamp.diff
        http://www.mail-archive.com/dccp@vger.kernel.org/msg01645.html

All subsequent patches which depended on these patches
have been modified using the following vim-expressions:

	s#skb_get_timestamp(skb,#dccp_timestamp(sk,#gc
	s#do_gettimeofday(#dccp_timestamp(sk,#gc

There are no other changes, which is why the patches
are not resubmitted. The number of patches in the first
patch has reduced from 25 to 19 (3 were committed, 3 withdrawn).

The following patch has changed in addition to the above:
 
 9f_CCID3-Macro-for-Moving-Average.diff

 This now uses the code sent by Arnaldo on 
   http://www.mail-archive.com/dccp@vger.kernel.org/msg01662.html
 and has been renamed into 9f_CCID3-Inline-for-Moving-Average.diff


II. Updates
=====All 66 updated patches have been uploaded to 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog

The entire updated changeset is again in
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/the_whole_lot.tar.gz

I have further updated the combined patch sets on 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/patches_working-set/
