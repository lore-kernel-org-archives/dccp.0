From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Tue, 15 Sep 2009 05:25:23 +0000
Subject: Re: [PATCH 1/5] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <5640c8aa0909142225q73e477fcga99a48c218d10e0b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
In-Reply-To: <cb00fa210909011944o46ba33dbn6d26c69f0a838411@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2009/9/15 Ivo Calado <ivocalado@embedded.ufcg.edu.br>
>
> Hi Gerrit and all.
> Thank you for your fast reply. My comments follow below
>
> >
> > net/dccp/ccids/lib/tfrc_equation_sp.c
> > -------------------------------------
> > This is a prime candidate for removal. After editing out the whitespace
> > differences, I found that it is 100% identical with tfrc_equation.c.
> >
> > The result of this editing has been uploaded to
> > http://eden-feed.erg.abdn.ac.uk/tfrc_sp_receiver_01.patch
> >
> One future patch will need to modify this file, but now it's really an
> exact copy.
>
>
Basically the rule with a patch set is that all the patches should
make sense together.

It may well be that it makes sense to make a copy, but if you want to
do this then present it with the patch that then modifies it.

Ian
