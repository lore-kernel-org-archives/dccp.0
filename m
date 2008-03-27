From: "Leandro Sales" <leandroal@gmail.com>
Date: Thu, 27 Mar 2008 00:44:32 +0000
Subject: Re: [DCCP] [Patch 0/7]: Bug-Fixes and Clean-Ups
Message-Id: <5bc4c4570803261744n3a557476qed3b8f52a2ce1def@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1206462011-24907-1-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1206462011-24907-1-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello Gerrit

On Tue, Mar 25, 2008 at 1:20 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This set contains bug-fixes and clean-ups.  The first two are already
>  in the test tree:
>
>  Patch #1: Fixes a bug where CCID-3 tries to sample the RTT while the
>           history is empty.
>           Leandro - I have added the same bug fix in the CCID-4 tree,
>           just after patch #24.

           That's ok!

>
>  Patch #2: Deprecates the Ack Ratio sysctl as per earlier discussion.
>
>
>  The following are kept back for the moment, since the first patch is
>  an RFC patch, and since a lot of the CCID-4 code depends on this:
>
>  Patch #3: Continues for consistency the earlier patch which removed the
>           long prefixes for CCID-3.
>           Arnaldo - can you please check. Also Leandro, can you also
>           check this - it has implications for CCID-4, too; which is
>           why I have not put it into the test tree immediately.

It's fine for me.

>
>  Patch #4: Fixes two sparse warnings.
>
>  Patch #5: Found out that RFC3390 code is identically applied in three
>           places (TCP, CCID-2, and CCID-3): this consolidates the
>           duplicated code.
>           Note: there is a fourth place where this code is duplicated
>                 (CCID-4), but this needs to be patched separately.

Please, see below.

>
>  Patch #6: Tidies up the slow-path input processing for DCCP (i.e. input
>           for states other than OPEN). This addresses some reordering
>           quirks by putting steps in their RFC4340-like order, ensures
>           that CCID/Ack Vector input is indeed confined to the fast-path,
>           and contains one bug fix.
>
>  Patch #7: Removes dead states, thanks to an observation by Leandro and
>           his colleagues.
>           Note: This would also need to be ported to CCID-4, since it
>                 uses the same (dead) states.

You're welcome!

>
>  If no one shouts, I will put that into the tree approximately by the end of
>  the week. In any case it would be good to know if the CCID-4 tree is still
>  active, since porting these changes will take quite a bit of work.

Yes, CCID-4 is still active. I'm very busy finishing many datails for
my dissertation, this includes writing the document, finishing some
DCCP for GStreamer fixes, and so on. I plan to back to CCID-4
implementation in the end of April, beginning of May.

>
>  In particular - patch #5 may be ported to CCID-4 as well, but it depends
>  on whether people find the code consolidation acceptable.

In my opinion it is ok.

Leandro.

>
>  The first two patches can be obtained in the sets from
>
>   (1) DCCP     git pull dccp://eden-feed.erg.abdn.ac.uk/dccp_exp +dccp:my_dccp
>   (2) CCID-4   git pull dccp://eden-feed.erg.abdn.ac.uk/dccp_exp +ccid4:my_ccid4
>  --
>  To unsubscribe from this list: send the line "unsubscribe dccp" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
