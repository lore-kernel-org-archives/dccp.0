From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 12 Apr 2007 11:19:41 +0000
Subject: [ANNOUNCE]: General remarks on patch submission
Message-Id: <200704121219.41919@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

please allow a few general comments to avoid further misunderstandings and complications.

Several of you are more from a research background than from a developer background. The diversity
on this list often creates communication differences which have a paralysing effect on progress:

 * often a patch submission breaks out into a discussion thread which continues for weeks and
   months, while the the patch meanwhile "brews" unchanged somewhere;

 * often parties defend their arguments from a wide range of diverse perspectives:
       o the draft/specification perspective;
       o one's own research agenda;
       o network safety;
       o operational stability of the implementation.
   Within one's scope one is of course right, but the perspectives are not all compatible.

 * One can only one thing at a time: research discussions or fixing implementation problems.
   There is only one time budget for both activities.

In short:
==== * My patches are all well-documented, are in chunks of a single logical change per patch, and I do
   much to make the patch reviewing as straightforward as possible. I don't know if you will get that
   on other lists; in any case what I am asking for in return is that these patches are dealt with
   fairly and with reference directly to the code, and less global research questions.

 * While I try my best to cooperate information-wise, I simply don't have the time to participate
   in long discussion threads (especially when triggered by just a few lines of code). If there is
   group-wise agreement, I'll be happy to update the patch set if a majority of people support an
   update they have agreed on, but I would like to limit discussion to the code content of patches.

 * I will accept / fix / and track down every single technical implementation issue which someone 
   points out to me in a patch. I am not insisting on accepting second-class material, but I want 
   a fair review for the material which has indeed cost hard work.


To illustrate what I mean, here are the last patch statistics (since March):

 Documentation/networking/dccp.txt   |   22    19     3     0
 include/linux/dccp.h                |   67    42    25     0 +-
 net/dccp/ackvec.c                   |    4     2     2     0
 net/dccp/ccids/Kconfig              |   12     8     4     0
 net/dccp/ccids/ccid2.c              |    2     1     1     0
 net/dccp/ccids/ccid3.c              |  867   322   545     0 +++++++++++++-----------------------
 net/dccp/ccids/ccid3.h              |   83    44    39     0 +--
 net/dccp/ccids/lib/Makefile         |    3     2     1     0
 net/dccp/ccids/lib/loss_interval.c  |  238   140    98     0 +++++----
 net/dccp/ccids/lib/loss_interval.h  |   74    46    28     0 +--
 net/dccp/ccids/lib/packet_history.c |  455   327   128     0 +++++++++++++-----
 net/dccp/ccids/lib/packet_history.h |  210   116    94     0 ++++----
 net/dccp/ccids/lib/tfrc.h           |   30    26     4     0 +
 net/dccp/ccids/lib/tfrc_module.c    |   44    44     0     0 +
 net/dccp/dccp.h                     |   33    27     6     0 +
 net/dccp/input.c                    |  129    81    48     0 +++--
 net/dccp/minisocks.c                |    1     0     1     0
 net/dccp/options.c                  |   62    30    32     0 +-
 net/dccp/output.c                   |   75    50    25     0 ++-
 net/dccp/proto.c                    |  176   119    57     0 ++++---
 net/dccp/sysctl.c                   |   10    10     0     0
 21 files changed, 1456 insertions(+), 1141 deletions(-)


There are almost as many deletions as insertions (in CCID3 the factor is close to 2).

Which means that this work is conservative, mostly dumb, clerical review-type. 
I am not complaining, but such work  - fishing out all the bugs - is required to obtain a useable stack.

I last discovered this when writing a simple socket application - that bombed out, which lead to the 
patches on closing/termination state; which in turn lead to the patches regarding the Sync-floods.
