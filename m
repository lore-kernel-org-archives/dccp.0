From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 01 Oct 2008 19:37:31 +0000
Subject: Re: Protocol not attached
Message-Id: <20081001193731.GD15840@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Oct 02, 2008 at 08:32:20AM +1300, Ian McDonald escreveu:
> >
> > Just completing the information. Using 2.6.26 on arm worked.
> >
> > Time to use git-bisect then I would guess...

Yes, its possible that this problem is not DCCP specific, perhaps
affecting SCTP too. I.e. both are loadable modules usually, while TCP is
always builtin.

- Arnaldo
