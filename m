From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Date: Wed, 31 Oct 2007 11:55:19 +0000
Subject: Re: [PATCH 13/25] Share TFRC feedback types struct via ccid34_lib
Message-Id: <20071031115519.GB3962@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200710310959.15075@strip-the-willow>
In-Reply-To: <200710310959.15075@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Oct 31, 2007 at 09:59:14AM +0000, Gerrit Renker escreveu:
> I have a suggestion regarding types, names, and things shared between
> CCID3 and CCID4 via dccp_tfrc_lib:
> 
> I think it would be best to name all such shared structures / names,
> when they are to appear in the dccp_tfrc_lib, as `tfrc_xxx' instead of
> `ccid34_xxx'
> 
> For example,
> 
> enum tfrc_fback_type {
> // ...
> };
>  
> instead of:
> 
> |  enum ccid34_fback_type {
> |  + FBACK_NONE = 0,
> |  + FBACK_INITIAL,
> |  + FBACK_PERIODIC,
> |  + FBACK_PARAM_CHANGE
> |  +};
> 
> There are no mechanisms other than TFRC (current work builds around TFRC, rather than entirely new schemes)
> so I think that this naming scheme is safe; and it would be consistent throughout the library.
> 
> I'd hope that Arnaldo and Ian add their take if they disagree or have other suggestions.

I agree that for things which concept comes from TFRC and are used in
one of the TFRC based DCCP CCIDs the best possible namespace is tfrc_.
If not we'll have to rename everything again when CCID5 comes if it is
also based on TFRC 8-)

And after all, even before ccid4 appeared on the radar I created
dccp_tfrc_lib, include/linux/tfrc.h, etc exactly for sharing code with
potentially new CCIDs that were based on TFRC.

- Arnaldo
