From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Thu, 20 Sep 2007 21:23:55 +0000
Subject: Re: [PATCH 4/4] CCID4: Replaces the hard-coded 1460 nominal packet size by a #define
Message-Id: <5bc4c4570709201423v415e73c9h79da7bf5e482bfd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201055m200ca6enbcc7d33070f7e792@mail.gmail.com>
In-Reply-To: <5bc4c4570709201055m200ca6enbcc7d33070f7e792@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/20, Tommi Saviranta <wnd@iki.fi>:
> On Thu, Sep 20, 2007 at 14:55:09 -0300, ツ Leandro Sales wrote:
> > diff -uprN dccp-ccid4.base/net/dccp/ccids/ccid4.h
>
> > +#define NOM_PACKET_SIZE                 1460
>
> Agreed, using a define for hardcoded value is the way to go. I think
> nominal packet size is somewhat private information to ccid4.c, so I'd
> rather put the define in the c-file. What does the Linux-kernel coding
> convention (or common sense) say about this?
>
>

Put NOM_PACKET_SIZE into ccid4.h follows the other definition, similar to
#define TFRC_T_MBI 64
that goes into ccid4.h too.

Leandro.
