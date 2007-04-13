From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 12:49:07 +0000
Subject: Re: [PATCH 4/25]: Cheaper & smaller timestamping
Message-Id: <200704131349.07674@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.22972@strip-the-willow>
In-Reply-To: <200703211844.22972@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > I have tested on various i386 instances (where it is `long') and on sp=
arc64 (where it is `int', as
|  > in parisc). =A0I was just calculating - there is indeed a chance to pr=
oduce overflow, since we add
|  > in timeval_add_usecs (since it is a signed type, the same problem seem=
s to reappear in timeval_sub_usecs).
|  >
|  > I don't have accurate figures at the moment with regard to overflow, b=
ut I assume that it is better to revert
|  > this patch?
|  >
|  > There is a related question =A0- with the new timesystem, should we co=
nvert to __get_realtime_clock_ts(), as
|  > the comment above do_gettimeofday() says in kernel/timer.c ?
|  >
|  > I would be glad for clarification, since there are quite a few patches=
 to update.
| =20
|  I'd say leave the dccp_timestamp alone for now, I have to read a bit
|  more on the new time system and what was done on the net schedulers,
|  etc before being able to say something meaningful on this aspect.
| =20
Just to be on the safe side then I will revert this patch 4/25 so that ever=
ything again uses dccp_epoch, ok?
