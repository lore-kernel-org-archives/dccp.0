From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 07 Feb 2012 00:39:28 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <20120207003928.GA5021@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Jordi,

the BUG_ON in net/dccp/ccids/ccid3.c catches a condition where the loss
event rate is not 0 (meaning that a loss occurred), while X_calc = 0.

This condition appears in step (4) of RFC 3448, 4.3 where X_calc is
computed. If it just changed from 0, then ccid3_hc_tx_packet_recv()
should have triggered the computation. Since s > 0, X_calc can not be
0 after that computation, due to the way tfrc_calc_x() computes 
X_calc = s/(R * table_lookup(p)). Most of the computation needs 64bits
to avoid truncating the numbers.

When the BUG_ON is triggered (p > 0 but X_calc = 0), it would cause the
sender to lock up, since several expressions use min(X_calc, ...), it
would not send anything and just hang.

The BUG_ON is there to catch the condition. Rather than having the sender
hanging when this unexpected case occurs, it signals that something is
severely wrong.

I can not say at the moment what in the 2.6.35.4 code could have triggered
the condition. If it is a non-64 bit architecture, it could be conversion
issues.

Rather than speculating, I would like to encourage you to try the test tree
instead. In several years of testing this bug has not yet been reported on
the mailing list. I just checked how much has changed in net/dccp/ccids/ccid3.c
since 2.6.35-rc4, and it is quite a lot:
 ccid3.c |  618 ++++++++++++++++++++++++----------------------------------------
 1 file changed, 241 insertions(+), 377 deletions(-)

Doing the same difference between original netdev tree and DCCP test tree gives
 ccid3.c |  366 ++++++++++++++++++++++++++--------------------------------------
 1 file changed, 153 insertions(+), 213 deletions(-)

There are changes in other files (tfrc library files) too.

Hence it is very much possible that the described condition does not appear
on kernel with test tree patch.

There are two ways forward:

 * you could download the patched and bziped tarball

   http://eden-feed.erg.abdn.ac.uk/latest-dccp-ccid4-test-tree.tar.bz2

   which has the advantage that nothing needs to be patched, just the .config
   needs to be updated;

 * the alternative is to 
   - clone the git tree from git://eden-feed.erg.abdn.ac.uk/dccp_exp
   - check out the 'dccp' branch (git co dccp)
   - do a diff backwards: git diff v2.6.35-rc4.. net/dccp > dccp.diff
   - apply the diff

The second approach could fail since it may require updating other parts
of the kernel that have since changed. You could avoid this by only looking
at the ccid3 changes, with some care.

Using the latest and up-to-date tree is the best alternative. Feel free to
contact me offline should this cause hurdles.

Gerrit
