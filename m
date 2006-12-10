From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 10 Dec 2006 01:37:51 +0000
Subject: Re: [Patch 0/12]:
Message-Id: <39e6f6c70612091737w39a4fcf6q3f48b109471c0b22@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612072112.10572@strip-the-willow>
In-Reply-To: <200612072112.10572@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/9/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 12/8/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > |  I presume these will be up on the web shortly?
> > Yes sorry I forgot to sync yesterday evening.
> > Everything now online exactly as posted.
> >
> You have some whitespace issues with three of these patches:
>
> Importing patch "15d_finer-grained_send-rate_resolution.diff"...Space
> in indent is followed by a tab.
> ../gerrit/15d_finer-grained_send-rate_resolution.diff:208:
>                                    (hctx->ccid3hctx_s << 6) /
> Space in indent is followed by a tab.
> ../gerrit/15d_finer-grained_send-rate_resolution.diff:209:
>                                                  (2*TFRC_T_MBI));
> warning: 2 lines add trailing whitespaces.
>  done
>
> Importing patch "16k_re-order_packet-history-h.diff"...Space in indent
> is followed by a tab.
> ../gerrit/16k_re-order_packet-history-h.diff:155:
>                         const u32 ndp,
> Space in indent is followed by a tab.
> ../gerrit/16k_re-order_packet-history-h.diff:186:
>             u8 *ccval);
> warning: 2 lines add trailing whitespaces.
>  done
>
> Importing patch "17_CCID3_fix-scaling-type-cast.diff"...Space in
> indent is followed by a tab.
> ../gerrit/17_CCID3_fix-scaling-type-cast.diff:29:
>                                             TFRC_T_MBI);
> warning: 1 line adds trailing whitespaces.
>  done

I'm rebasing my tree and in the process I'm using git-am
--whitespace=strip on the whole 22 patches series.

- Arnaldo
