From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 12:19:31 +0000
Subject: Re: [PATCH 4/25]: Cheaper & smaller timestamping
Message-Id: <200704131319.31362@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.22972@strip-the-willow>
In-Reply-To: <200703211844.22972@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  On 4/2/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > | =A0> [DCCP]: Cheaper & smaller timestamping
|  >
|  > | =A0A couple of comments though:
|  > | =A0- this is how I had the code originally in many cases and Arnaldo
|  > | =A0changed - can't remember why.
|  > Arnaldo's code uses a reference point, the skb_get_timestamp() also did
|  > that. May be useful against old incarnations across reboots.
| =20
|  I got to this cset now in today's merge session, the cset that did that =
was:
| =20
|  b0e567806d16586629468c824dfb2e71155df7da
| =20
|  Comment was, unfortunately, not so clear:
| =20
|  ----
|  [acme@mica net-2.6.22]$ git-show b0e567806d16586629468c824dfb2e71155df7da
|  commit b0e567806d16586629468c824dfb2e71155df7da
|  Author: Arnaldo Carvalho de Melo <acme@mandriva.com>
|  Date: =A0 Fri Sep 9 02:38:35 2005 -0300
| =20
|  =A0 =A0 [DCCP] Introduce dccp_timestamp
| =20
|  =A0 =A0 To start the timestamps with 0.0ms, easing the integer maths in
|  the CCIDs, this
|  =A0 =A0 probably will be reworked to use the to be introduced struct tim=
eval_offset
|  =A0 =A0 infrastructure out of skb_get_timestamp, etc.
| =20
|  =A0 =A0 Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
|  ---
| =20
|  What are the architectures you've been testing? All 64 bits? IIRC the
|  problem was related to overflows, suseconds_t is unsigned long, so 32
|  bits on i386...
I have tested on various i386 instances (where it is `long') and on sparc64=
 (where it is `int', as
in parisc).  I was just calculating - there is indeed a chance to produce o=
verflow, since we add
in timeval_add_usecs (since it is a signed type, the same problem seems to =
reappear in timeval_sub_usecs).

I don't have accurate figures at the moment with regard to overflow, but I =
assume that it is better to revert
this patch?

There is a related question  - with the new timesystem, should we convert t=
o __get_realtime_clock_ts(), as
the comment above do_gettimeofday() says in kernel/timer.c ?

I would be glad for clarification, since there are quite a few patches to u=
pdate.

Cheers.

