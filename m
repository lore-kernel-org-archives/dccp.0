From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Thu, 20 Sep 2007 17:53:05 +0000
Subject: [PATCH 0/4] CCID 4: adjusts the initial implementation of CCID-4
Message-Id: <5bc4c4570709201053q35b3c504s43d2e0e57322cfd4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Leandro Sales <leandro@embedded.ufcg.edu.br>

Re-submitting my initial patchset for CCID-4, merging them against
Tommi patcheset and providing some updates/improvements/organization.

Since me and Tommi provided similar initial patches for Kconfing, ccid4.{h/c},
Makefile and include/linux/dccp.h, this patchset provides just diffs not
presented in the Tommi patchset it provide code refactory and fix to the help
for Kconfig CCID-4. The both patchset (from mine and Tommi) was based on the
CCID-3 implementation, and in addition to patches provided by Tommi, which is
very similar to the mine, I suggest the following changes:

Patch #1: signs off patch #1 submitted by Tommi and it provides improvements/
organization to the initial entries for CCID 4 to net/dccp/ccids/Kconfig

Patch #2: it provides organization to the initial entries for CCID 4 to
net/dccp/ccids/Makefile.

Patch #3: signs off patch #2 submitted by Tommi and it organize the copyright
and comments.

Patch #4: replace the hard-coded 1460 nominal packet size by a #define in the
ccid4.h and adjust the ccid4.c for the applied changes
