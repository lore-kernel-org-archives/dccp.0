From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 22:08:43 +0000
Subject: [PATCH 7/25] Initial lib for sharing common code between ccid-3/ccid-4
Message-Id: <5bc4c4570711011508g6d1f671dy4dbc6ade071b7a1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.24513.leandroal@gmail.com>
In-Reply-To: <200710312130.24513.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Just forward a private e-mail with Tommi about his comments.

2007/11/1, Tommi Saviranta <wnd@iki.fi>:
> On Wed, Oct 31, 2007 at 21:30:24 -0300, Leandro wrote:
> > [CCID-3/4 lib] Initial lib for sharing common code between ccid-3/ccid-4
> >
> > The lib is called tfrc_ccids.o
>
> > Index: leandro.new/net/dccp/ccids/lib/Makefile
> > =================================> > --- leandro.new.orig/net/dccp/ccids/lib/Makefile
> > +++ leandro.new/net/dccp/ccids/lib/Makefile
> > @@ -1,4 +1,5 @@
> >  obj-$(CONFIG_IP_DCCP_TFRC_LIB) += dccp_tfrc_lib.o
> >
> >  dccp_tfrc_lib-y := tfrc_module.o    tfrc_equation.o \
> > -                   packet_history.o loss_interval.o
> > +                   packet_history.o loss_interval.o \
> > +                tfrc_ccids.o
>
> Whitespace police hits! I don't remember Documentation/CodingStyle
> mentioning anything about whitespaces in Makefiles. Nevertheless,
> packet_history.o is indented here with spaces, tfrc_ccids.o with
> tabulators, I think we should stick to just one kind of whitespace.
>
> > -                   packet_history.o loss_interval.o
> > +                   packet_history.o loss_interval.o \
> > +                   tfrc_ccids.o
>
>

From Documentation/CodingStyle:

"Tabs are 8 characters, and thus indentations are also 8 characters.
There are heretic movements that try to make indentations 4 (or even 2!)
characters deep, and that is akin to trying to define the value of PI to
be 3."

(...)

"In short, 8-char indents make things easier to read, and have the added
benefit of warning you when you're nesting your functions too deep.
Heed that warning."

So, the kind that we are looking for it to use tabs (8 chars). Since
tfrc_ccids.o I used tabs, I think that it is ok.

Leandro.
