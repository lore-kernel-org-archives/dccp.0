From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 22 Sep 2007 20:32:19 +0000
Subject: Re: [PATCH 4/4] CCID4: Replaces the hard-coded 1460 nominal packet size by a #define
Message-Id: <5640c7e00709221332y7282f4acn7942222b75eb435@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201055m200ca6enbcc7d33070f7e792@mail.gmail.com>
In-Reply-To: <5bc4c4570709201055m200ca6enbcc7d33070f7e792@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/22/07, Tommi Saviranta <wnd@iki.fi> wrote:
> On Thu, Sep 20, 2007 at 18:23:55 -0300, ツ Leandro Sales wrote:
> > Put NOM_PACKET_SIZE into ccid4.h follows the other definition, similar
> > to
> > #define TFRC_T_MBI 64
> > that goes into ccid4.h too.
>
> Fair enough.
>
> Signed-off-by: Tommi Saviranta <wnd@iki.fi>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
(although I think there should be just one merged patch for this)
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
