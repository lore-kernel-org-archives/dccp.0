From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 21 Apr 2008 16:17:00 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version of Tomasz's patch set
Message-Id: <200804211817.01189.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 21 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82:
> Em Mon, Apr 21, 2008 at 01:45:20PM +0200, Patrick McHardy escreveu:
> > Tomasz Grobelny wrote:
> >> 2. If the sole purpose of this change was to keep skb->cb zeroed then =
it
> >> doesn't seem to me like the right solution. Wasting about 20 bytes
> >> instead of zeroing them when needed I would consider at least weird. I
> >> understand that TCP and UDP may have enough space left but it just
> >> turned out that DCCP doesn't.
> >
> > It was the safest solution that late in a release. It also
> > avoids to memset the cb unnecessarily. If the room is not
> > enough anymore, its easy to go back to using memset.
>
> Nod, if we don't need the space reserved for the lower layer protocols
> in DCCP it is actually the best solution, as we don't need to zero the
> cb again before passing it to IP, it gets zeroed at alloc_skb time and
> that is it. If we need the space, we have to pay the price of
> memset before passing to IP.
>
Ok, so in this case the patch for DCCP could be reverted in test tree, is t=
hat=20
right? Were these two deleted memsets zeroing all that was necessary or wer=
e=20
there any other bugs fixed by the patch?
If we iron this out we could finally return to the main subject of this=20
thread. That is Patch v2 by me and Gerrit...
--=20
Regards,
Tomasz Grobelny
