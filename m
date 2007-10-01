From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 01 Oct 2007 18:57:21 +0000
Subject: Re: [PATCH 8/9]: Set per-connection CCIDs via socket options
Message-Id: <20071001185721.GA7881@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.33024@strip-the-willow>
In-Reply-To: <200709281630.33024@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Oct 02, 2007 at 07:51:45AM +1300, Ian McDonald escreveu:
> On 9/29/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > [DCCP]: Set per-connection CCIDs via socket options
> >
> > With this patch, TX/RX CCIDs can now be changed on a per-connection basis, which
> > overrides the defaults set by the global sysctl variables for TX/RX CCIDs.
> >
> > To make full use of this facility, the remaining patches of this patch set are
> > needed, which track dependencies and activate negotiated feature values.
> >
> > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> 
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> 
> But see one comment below.
> 
> > +       BUILD_BUG_ON(sizeof(u8) != 1);
> 
> The whole point of u8 is that it is one byte as is u16 2 bytes etc. If
> these change then the whole kernel breaks so this check is
> unnecessary.

Agreed.

- Arnaldo
