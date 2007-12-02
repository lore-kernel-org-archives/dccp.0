From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 02 Dec 2007 21:36:49 +0000
Subject: [RFC][PATCHES 0/7]: Reorganization of RX history patches
Message-Id: <1196631416-17778-1-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

WARNING: After reading some messages from Ingo Molnar on lkml I think we should really
         trim the number of lists we use for kernel development. And since I moved
	 back to using mutt for reading e-mails, something I should have never, ever
	 stopped doing, I guess we should move the DCCP discussions to netdev,
	 where we hopefully can get more people interested and reviewing the work we
	 do, so please consider moving DCCP discussion to netdev@vger.kernel.org,
	 where lots of smart networking folks are present and can help our efforts
	 on turning RFCs to code.

Back to business...:

Hi Gerrit,

	Please take a look at this patch series where I reorganized your work on the new
TFRC rx history handling code. I'll wait for your considerations and then do as many
interactions as reasonable to get your work merged.

	It should be completely equivalent, plus some fixes and optimizations, such as:

. The code that allocates the RX ring deals with failures when one of the entries in
  the ring buffer is not successfully allocated, the original code was leaking the
  successfully allocated entries.

. We do just one allocation for the ring buffer, as the number of entries is fixed we
  should just do one allocation and not TFRC_NDUPACK times.

. I haven't checked if all the code was commited, as I tried to introduce just what was
  immediatelly used, probably we'll need to do some changes when working on the merge
  of your loss intervals code.

. I changed the ccid3_hc_rx_packet_recv code to set hcrx->ccid3hcrx_s for the first
  non-data packet instead of calling ccid3_hc_rx_set_state, that would use 0 as the
  initial value in the EWMA calculation.

. I also moved some patch parts (hunks) around trying to improve the readability of
  the patches, trying to get things that logically replaced what was there before
  closer together.

. Separation of parts of your patches and combination of others is also another thing
  you'll see in this patch set. I understand that it is difficult to find the right
  compromise and I hope you don't feel too bad with the decisions I made, eventually
  we'll find a common ground.

. Another change was related to namespacing, I added tfrc_rx_hist_ to a number of
  functions and in some cases just normalised the naming to be consistent.

. I'm not that happy with deferring changes to the loss intervals code that uses
  rx handling data structures, but I'm OK with leaving some code commented out till
  we get to merging the new loss intervals code.

	For what is worth I leave her my deep appreciation of your work and also my
(repeated) apologies for not being able to do these kinds of review sessions months ago,
but I also I'm willing and able to cure these shortcomings by continuing the work I've
been doing recently on finally reviewing your hard work, keep it up!

	It is available at:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25

Best Regards,

- Arnaldo

 b/net/dccp/ccids/Kconfig                       |   13
 b/net/dccp/ccids/ccid3.c                       |   35 -
 b/net/dccp/ccids/ccid3.h                       |   14
 b/net/dccp/ccids/lib/Makefile                  |    2
 b/net/dccp/ccids/lib/loss_interval.c           |   14
 b/net/dccp/ccids/lib/packet_history.c          |   27 -
 b/net/dccp/ccids/lib/packet_history.h          |    3
 b/net/dccp/ccids/lib/packet_history_internal.h |   68 +++
 b/net/dccp/ccids/lib/tfrc.c                    |   48 ++
 b/net/dccp/ccids/lib/tfrc.h                    |   18
 b/net/dccp/dccp.h                              |   13
 net/dccp/ccids/ccid3.c                         |  289 ++++----------
 net/dccp/ccids/lib/loss_interval.c             |   14
 net/dccp/ccids/lib/packet_history.c            |  483 +++++++++++++------------
 net/dccp/ccids/lib/packet_history.h            |  175 +++------
 15 files changed, 602 insertions(+), 614 deletions(-)
