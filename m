From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Fri, 13 Apr 2007 13:05:30 +0000
Subject: Re: [PATCH 4/25]: Cheaper & smaller timestamping
Message-Id: <39e6f6c70704130605h3c2bdc97u73ebb9caf66b3054@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.22972@strip-the-willow>
In-Reply-To: <200703211844.22972@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Arnaldo Carvalho de Melo:
> |  > I have tested on various i386 instances (where it is `long') and on sparc64 (where it is `int', as
> |  > in parisc). I was just calculating - there is indeed a chance to produce overflow, since we add
> |  > in timeval_add_usecs (since it is a signed type, the same problem seems to reappear in timeval_sub_usecs).
> |  >
> |  > I don't have accurate figures at the moment with regard to overflow, but I assume that it is better to revert
> |  > this patch?
> |  >
> |  > There is a related question - with the new timesystem, should we convert to __get_realtime_clock_ts(), as
> |  > the comment above do_gettimeofday() says in kernel/timer.c ?
> |  >
> |  > I would be glad for clarification, since there are quite a few patches to update.
> |
> |  I'd say leave the dccp_timestamp alone for now, I have to read a bit
> |  more on the new time system and what was done on the net schedulers,
> |  etc before being able to say something meaningful on this aspect.
> |
> Just to be on the safe side then I will revert this patch 4/25 so that everything again uses dccp_epoch, ok?

Yes

- Arnaldo
