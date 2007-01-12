From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 12 Jan 2007 19:14:01 +0000
Subject: Re: [PATCH 1/1]: Remove build warnings on 64-bit architecture
Message-Id: <39e6f6c70701121114x1054cdbscea4f5b9c195f3c7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701121758.21516@strip-the-willow>
In-Reply-To: <200701121758.21516@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/12/07, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 13/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:

<SNIP>

> > @@ -899,7 +901,7 @@ static void ccid3_hc_rx_packet_recv(stru
> >                 DCCP_BUG_ON(r_sample < 0);
> >                 if (unlikely(r_sample <= t_elapsed))
> >                         DCCP_WARN("r_sample=%ldus, t_elapsed=%ldus\n",
> > -                                 r_sample, t_elapsed);
> > +                                 (long)r_sample, (long)t_elapsed);
> >                 else
> >                         r_sample -= t_elapsed;
> >                 CCID3_RTT_SANITY_CHECK(r_sample);
> > -
>
> I can't comment on suseconds stuff as don't know so much...

Checked this last month, look at the URL to see the diff:

http://www.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;hba78b6cba14bd37fdb12c5367f1e4d58ff2e0f

commit 1fba78b6cba14bd37fdb12c5367f1e4d58ff2e0f
Author: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date:   Sun Dec 10 15:39:29 2006 -0200

    [DCCP] ccid3: Fixup some type conversions related to rtts

    Spotted by David Miller when compiling on sparc64, I reproduced it here on
    parisc64, that are the only platforms to define __kernel_suseconds_t as an
    'int', all the others, x86_64 and x86 included typedef it as a
'long', but from
    the definition of suseconds_t it should just be an 'int' on
platforms where it
    is >= 32bits, it would not require all the castings from
suseconds_t to (int)
    when printking variables of this type, that are not needed on parisc64 and
    sparc64.

    Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
