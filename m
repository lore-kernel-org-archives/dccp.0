From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 12 Mar 2007 22:04:18 +0000
Subject: Re: [ANNOUNCE]: Patch Preview
Message-Id: <5640c7e00703121504x2da566b3p54b4112adc0a0dc5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703121557.12709@strip-the-willow>
In-Reply-To: <200703121557.12709@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On 3/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I have put quite a lot of work into
>   * bringing CCID 3 up to spec
>   * implement loss detection according to RFC 3448/4342
>   * add loss intervals handling according to rfc3448bis
>   * many cool new features
>   * ample documentation, applications, and test modules for most features

Gerrit,

This sounds great. Well done!
>
> 3. MISSED? I am not sure if I have missed Sign-offs or Acked-byes. Ian (a=
nd others) can you please
>    check that http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/
>    is correct? In particular, only the following two out of 25 are not ac=
ked/signed-off:
>     * http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/3e_CCID3_=
send_time_race_condition.diff
>       (but I believe you said you were ok with it, since the patch was ch=
anged  to update t_ipi when `s' changes)

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

>     * http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/4a_debug_=
always_no_module.diff
>

I'm not so confident when it comes to the debugging code which is why
I didn't comment. One thing is I notice this code which looks like it
could be useful if ported to DCCP:
http://master.kernel.org/git/?p=3Dlinux/kernel/git/davem/net-2.6.22.git;a=
=3Dcommit;h=8E2101a9faab43dcf307d46784a1ede7997fe729

This allows turning debug code on/off by sysctl.

> 4. SUMMARY of patch sets 2 and 3:
>
>         * avoiding accumulation of sending credits
>         * faster & more efficient time-stamping (timestamps from NIC)
>         * honour initial (SYN handshake) RTT estimate
>         * implement rfc3448bis nofeedback timer handling
>                 - ignore feedback after nofeedback timer expiry when p=3D0
>                 - do not reduce X after nofeedback timer expiry
>         * implement larger initial windows as described in rfc3448bis
>         * resolve locking issues for SMP
>                 - atomic context between sending packet & updating CCID s=
tructures
>                 - atomic context when updating t_nom
>                 - protect transmitter data structures against asynchronou=
s changes
>                 - keep garbage collection separate from access
>
>         * clean up and minimize socket data structures
>         * allow retrieving current Maximum Packet Size via socket option
>         * compilation fixes for 64-bit architectures
>         * function for distinguishing `data' and `non-data' (NDP) packet =
types
>         * routines to perform modulo-16 (window counter CCval) arithmetic
>         * simplify the kernel API (split functionality into modules)
>         * completely revised RX history structure
>                 - circular list using only minimum of entries
>                 - object-oriented programming interface (like abstract da=
ta type)
>                 - reusing the same structure for both RTT sampling and lo=
ss detection
>                 - generic service, available to other CCIDs
>         * loss detection
>                 - cope with delayed, late, and re-ordered packets
>                 - detect when a sequence hole is later filled
>                 - take NDP information into account
>                 - assign losses of the same RTT to the same loss event
>                 - recycle history structures after loss detection (cope w=
ith loss bursts)
>
>         * loss interval management
>                 - also ring list since simplifies interface
>                 - object-oriented programming interface (like abstract da=
ta type)
>                 - on-demand allocation: less memory consumption on loss-f=
ree connections
>                 - handing over from loss detection to loss interval histo=
ry completely automated
>                   by module (reusable for future CCIDs)
>
> Enjoy,
> Gerrit
>
The new patches sound great but I find them hard to review all
combined. Arnaldo has asked for a git tree I see. Can that be
provided, or I prefer your directory structure of patches so I can
read though them? You implied that you had done this for new patches
but I can't actually find it.

Again - this looks like a great step forward.

Ian
--=20
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
