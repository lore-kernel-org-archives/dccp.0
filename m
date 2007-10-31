From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 31 Oct 2007 09:59:14 +0000
Subject: Re: [PATCH 13/25] Share TFRC feedback types struct via ccid34_lib
Message-Id: <200710310959.15075@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have a suggestion regarding types, names, and things shared between
CCID3 and CCID4 via dccp_tfrc_lib:

I think it would be best to name all such shared structures / names,
when they are to appear in the dccp_tfrc_lib, as `tfrc_xxx' instead of
`ccid34_xxx'

For example,

enum tfrc_fback_type {
// ...
};
 
instead of:

|  enum ccid34_fback_type {
|  + FBACK_NONE = 0,
|  + FBACK_INITIAL,
|  + FBACK_PERIODIC,
|  + FBACK_PARAM_CHANGE
|  +};

There are no mechanisms other than TFRC (current work builds around TFRC, rather than entirely new schemes)
so I think that this naming scheme is safe; and it would be consistent throughout the library.

I'd hope that Arnaldo and Ian add their take if they disagree or have other suggestions.
