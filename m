From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Thu, 09 Nov 2006 21:55:51 +0000
Subject: Re: Sequence numbers in Response packets (Linux 2.6.17)
Message-Id: <39e6f6c70611091355l58dbb1bfoe0979ee5ea2069b0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <E1GSY22-000OxT-00.vladivm-mail-ru@f75.mail.ru>
In-Reply-To: <E1GSY22-000OxT-00.vladivm-mail-ru@f75.mail.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/9/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > Although this is a relatively minor bug, I believe it would be better to stick by the DCCP rule
> > that `each outgoing packet has its sequence number incremented' and will send a patch.
> >
> > Ian, I will remove this ToDo from the list, ok?
> >
> > Thanks to Vladimir for pointing this out; but it would in future be much more helpful to
> > have some real traces to work on - otherwise it really is hard to figure out the causes.
> >
> > Gerrit
> >
> >
> Thanks Gerrit for doing the legwork on this one. As you say the bug is
> more minor than first identified. I'm happy for you to update the ToDo
> list with this info or remove once you've sent your patch.
>
> You're doing well to work through these. Just wish I had more time to help!

Even not being a dilligent maintainer in the last months, I'm very,
very happy indeed with the community slowing being formed around the
Linux DCCP codebase, I'll try not to miss the 2.6.20 merge window to
get Gerrit patch queue merged after reviewing it.

Thanks everybody for validating what is there and for working on
fixing and implementing new stuff.

- Arnaldo
