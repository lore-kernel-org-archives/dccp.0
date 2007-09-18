From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Tue, 18 Sep 2007 23:07:55 +0000
Subject: CONFLICT using git-pull
Message-Id: <5bc4c4570709181607n49026fa2pdda176bce4ea4d45@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,
   as for the implementation of CCID-4, I modified some files of the
gerrit git during last week and weekend and now I but to make a fetch
of te gerrit latest code. But when I type git-pull I'm getting the
following:

embedded-ephone1 dccp # git-pull
 100% (22666/22666) done
Removed arch/mips/mips-boards/sim/sim_int.c
Removed arch/mips/philips/pnx8550/common/Kconfig
Removed arch/mips/sni/pcimt_scache.c
Removed include/asm-mips/gt64240.h
Removed include/asm-mips/mach-ocelot/mach-gt64120.h
Removed include/asm-mips/marvell.h
Auto-merged include/linux/dccp.h
CONFLICT (content): Merge conflict in include/linux/dccp.h
Auto-merged net/dccp/input.c
CONFLICT (content): Merge conflict in net/dccp/input.c
Auto-merged net/dccp/options.c
CONFLICT (content): Merge conflict in net/dccp/options.c
Auto-merged net/dccp/proto.c
CONFLICT (content): Merge conflict in net/dccp/proto.c
Auto-merged net/dccp/timer.c
CONFLICT (content): Merge conflict in net/dccp/timer.c
Automatic merge failed; fix conflicts and then commit the result.

How to solve this issue? How can I name a kind of "override and
update" (the local file) for this CONFLICTED files?

Thanks,
Leandro.
