From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Wed, 31 Oct 2007 22:21:10 +0000
Subject: Re: [PATCH 13/25] Share TFRC feedback types struct via ccid34_lib
Message-Id: <5bc4c4570710311521o682bd3btc540263f2bcda9bf@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710310959.15075@strip-the-willow>
In-Reply-To: <200710310959.15075@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/10/31, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> Leandro,
>
> following Arnaldo's reply, can you please you the suggested naming scheme (it is also
> already used in packet_history.c and loss_interval.c): I will be looking into merging
> the patches with the CCID3 set of patches, to reduce work and duplication.
>
> The whole lot of CCID3 patches will then be re-submitted. Arnaldo, I would like to make
> your job easier by sending fewer patches (the CCID3 batch is 40 patches, plus Leandro's):
> would you be ok with a smaller number, e.g. 5..7?
>
> There will also be a short RFC before this (regarding locking), and I will make sure that
> the entire batch becomes fully bisectable.
>
> Gerrit
>
> Quoting Arnaldo Carvalho de Melo:
> |  > enum tfrc_fback_type {
> |  > // ...
> |  > };
> |  >
> |  > instead of:
> |  >
> |  > | enum ccid34_fback_type {
> |  > | + FBACK_NONE = 0,
> |  > | + FBACK_INITIAL,
> |  > | + FBACK_PERIODIC,
> |  > | + FBACK_PARAM_CHANGE
> |  > | +};
> |  >
> |  > There are no mechanisms other than TFRC (current work builds around TFRC, rather than entirely new schemes)
> |  > so I think that this naming scheme is safe; and it would be consistent throughout the library.
> |  >
> |  > I'd hope that Arnaldo and Ian add their take if they disagree or have other suggestions.
> |
> |  I agree that for things which concept comes from TFRC and are used in
> |  one of the TFRC based DCCP CCIDs the best possible namespace is tfrc_.
> |  If not we'll have to rename everything again when CCID5 comes if it is
> |  also based on TFRC 8-)
> |
> |  And after all, even before ccid4 appeared on the radar I created
> |  dccp_tfrc_lib, include/linux/tfrc.h, etc exactly for sharing code with
> |  potentially new CCIDs that were based on TFRC.
> |
>

Hello Gerrit,
    Yes, for sure! I also agree with you and Arnaldo on this and I'm
currently change to the namespace suggested by you and accepted by
Arnaldo.

Leandro
