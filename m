From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 16:14:17 +0000
Subject: Re: [PATCH 3/25] Adjustments of the ccid-4 copyright and kernel module authors
Message-Id: <5bc4c4570711010914g33a84781pcb48f5be894d58fc@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710312021.53536.leandroal@gmail.com>
In-Reply-To: <200710312021.53536.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/11/1, Tommi Saviranta <wnd@iki.fi>:
> On Thu, Nov 01, 2007 at 10:24:44 -0200, Arnaldo Carvalho de Melo wrote:
> > Em Thu, Nov 01, 2007 at 02:22:49PM +0200, Tommi Saviranta escreveu:
> > > On Wed, Oct 31, 2007 at 20:21:53 -0300, Leandro wrote:
> > > > - *  net/dccp/ccids/ccid4.h
> > > > + *  net/dccp/ccids/ccid4.c
> > >
> > > Is this intentional? ccid2.h and ccid3.h both have ccidX.h.
> >
> > I suggest just removing the file name altogether. Dave Jones has been
> > doing this and I agree with him that the names in these files are not
> > useful.
>
> Agreed.
>
>

It was not intentional, it was a wrong copy & paste operation, and I
already notice this, but I didn't want to release a patch just to fix
this, then I fix and when I provide new changes, I would include this
one, but since Arnaldo mentioned that this can be removed, and you
agreed, I will remove it in the next patch set.

[]s
Leandro.
