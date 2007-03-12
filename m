From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 12 Mar 2007 22:20:48 +0000
Subject: Re: [ANNOUNCE]: Patch Preview
Message-Id: <39e6f6c70703121520j50d71859jf408b8bb28d35fb3@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703121557.12709@strip-the-willow>
In-Reply-To: <200703121557.12709@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On 3/12/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 3/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > I have put quite a lot of work into
> >   * bringing CCID 3 up to spec
> >   * implement loss detection according to RFC 3448/4342
> >   * add loss intervals handling according to rfc3448bis
> >   * many cool new features
> >   * ample documentation, applications, and test modules for most featur=
es
>
> Gerrit,
>
> This sounds great. Well done!
> >
> > 3. MISSED? I am not sure if I have missed Sign-offs or Acked-byes. Ian =
(and others) can you please
> >    check that http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/
> >    is correct? In particular, only the following two out of 25 are not =
acked/signed-off:
> >     * http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/3e_CCID=
3_send_time_race_condition.diff
> >       (but I believe you said you were ok with it, since the patch was =
changed  to update t_ipi when `s' changes)
>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
>
> >     * http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/4a_debu=
g_always_no_module.diff
> >
>
> I'm not so confident when it comes to the debugging code which is why
> I didn't comment. One thing is I notice this code which looks like it
> could be useful if ported to DCCP:
> http://master.kernel.org/git/?p=3Dlinux/kernel/git/davem/net-2.6.22.git;a=
=3Dcommit;h=8E2101a9faab43dcf307d46784a1ede7997fe729
>
> This allows turning debug code on/off by sysctl.
>
> > 4. SUMMARY of patch sets 2 and 3:
> >
> >         * avoiding accumulation of sending credits
> >         * faster & more efficient time-stamping (timestamps from NIC)
> >         * honour initial (SYN handshake) RTT estimate
> >         * implement rfc3448bis nofeedback timer handling
> >                 - ignore feedback after nofeedback timer expiry when p=
=3D0
> >                 - do not reduce X after nofeedback timer expiry
> >         * implement larger initial windows as described in rfc3448bis
> >         * resolve locking issues for SMP
> >                 - atomic context between sending packet & updating CCID=
 structures
> >                 - atomic context when updating t_nom
> >                 - protect transmitter data structures against asynchron=
ous changes
> >                 - keep garbage collection separate from access
> >
> >         * clean up and minimize socket data structures
> >         * allow retrieving current Maximum Packet Size via socket option
> >         * compilation fixes for 64-bit architectures
> >         * function for distinguishing `data' and `non-data' (NDP) packe=
t types
> >         * routines to perform modulo-16 (window counter CCval) arithmet=
ic
> >         * simplify the kernel API (split functionality into modules)
> >         * completely revised RX history structure
> >                 - circular list using only minimum of entries
> >                 - object-oriented programming interface (like abstract =
data type)
> >                 - reusing the same structure for both RTT sampling and =
loss detection
> >                 - generic service, available to other CCIDs
> >         * loss detection
> >                 - cope with delayed, late, and re-ordered packets
> >                 - detect when a sequence hole is later filled
> >                 - take NDP information into account
> >                 - assign losses of the same RTT to the same loss event
> >                 - recycle history structures after loss detection (cope=
 with loss bursts)
> >
> >         * loss interval management
> >                 - also ring list since simplifies interface
> >                 - object-oriented programming interface (like abstract =
data type)
> >                 - on-demand allocation: less memory consumption on loss=
-free connections
> >                 - handing over from loss detection to loss interval his=
tory completely automated
> >                   by module (reusable for future CCIDs)
> >
> > Enjoy,
> > Gerrit
> >
> The new patches sound great but I find them hard to review all
> combined. Arnaldo has asked for a git tree I see. Can that be

No need for a git tree, I can apply it one by one here,what I said is
that what gerryt has is equivalent to a git tree, i.e. a series of
patches with comments and I don't want to lose that comments neither
the separation.

Will submit some more csets I have here for the skb layer header
pointers series and merge this after a quick review (famous last
words, lets see if its true today :-) ).

- Arnaldo
