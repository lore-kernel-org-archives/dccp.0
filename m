From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 13 Aug 2007 21:04:12 +0000
Subject: Re: CCID4 implementation for Linux DCCP
Message-Id: <5640c7e00708131404g4d05040bl345d28f416aadcbf@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070813125651.GA23965@kikai.katei.fi>
In-Reply-To: <20070813125651.GA23965@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/14/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> ---------- Forwarded message ----------
> From: ツ Leandro Sales <leandroal@gmail.com>
> Date: Tue, 14 Aug 2007 08:27:45 +1200
> Subject: Re: CCID4 implementation for Linux DCCP
> To: Tommi Saviranta <wnd@iki.fi>
>
>    What do you have until know? I suggest to share a git repository or
> to use the gerrits one to make the job easier to conduct.
>    I will appreciate your comments about that.
> Leandro
>
> On 8/14/07, Tommi Saviranta <wnd@iki.fi> wrote:
> > As a part of my thesis I will be working on an implementation of CCID4
> > for DCCP in Linux kernel using existing implementation of CCID3 as a
> > starting point. Since CCID3 isn't exactly ready or complete, I will be
> > merging its patches to CCID4 periodically.
> >
> > For now I will be using draft-floyd-dccp-ccid4-01.txt as reference. If
> > everything goes well, I'd be happy to see the code eventually reach the
> > mainline kernel.
> > -

Hi there,

I agree with Leandro that it should be based on Gerrit's tree as he
has done a lot of excellent work on the tree recently. This tree
dramatically changes CCID3 which I imagine you would use a lot of for
CCID4.

Have a look at:
http://linux-net.osdl.org/index.php/DCCP_Testing#Experimental_DCCP_source_tree

for instructions on how to use.

Remember to keep posting questions, code here. People will often give
comments on code and will help you.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
