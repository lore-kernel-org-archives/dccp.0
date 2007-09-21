From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Fri, 21 Sep 2007 13:20:31 +0000
Subject: Re: unchanged functions between ccid-3 and ccid-4
Message-Id: <5bc4c4570709210620w2b12709bge38075864d8faa7d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201928l270b24cdod359349ca3d3508@mail.gmail.com>
In-Reply-To: <5bc4c4570709201928l270b24cdod359349ca3d3508@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/21, Arnaldo Carvalho de Melo <acme@ghostprotocols.net>:
> Em Thu, Sep 20, 2007 at 11:28:52PM -0300, ツ Leandro Sales escreveu:
> > 2007/9/20, Ian McDonald <ian.mcdonald@jandi.co.nz>:
> > > On 9/21/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> > > > Hello Gerrit,
> > > >
> > > >    From now and as I was talking to Ian two days ago, after our
> > > > patchset for initial code of ccid-4, I'm identifying functions between
> > > > ccid-4 and ccid-3 that will remains unchangeable. What do you think if
> > > > we try to define something like a common_ccid34.{c/h} and make common
> > > > functions between ccid-4 and ccid-3 available into this source file?
> > > > Or this will make the code a little bit confused?
> > > >
> > > > Leandro.
> > > >
> > > Leandro,
> > >
> > > Firstly - I think these discussions are better on list. Can we open to list.
> > >
> > > Thinking some more about this I've thought about this some more. I
> > > think what we're bettter to do is to get CCID4 code to use CCID3 code
> > > rather than create a new file. This is because CCID4 references CCID3
> > > but not the other way around.
> > >
> > > It will also be messy if we then get CCID5 etc.
> > >
> > > So what I suggest you might need to do is shift more ccid3
> > > declarations into ccid3.h and included this. It might also need
>
> This part is OK if the functions are really small
>

OK

> > > removal of some static from function declarations and adding of
> > > EXPORT_SYMBOL_GPL to existing CCID3 code.
>
> This one is not because then we would have to load ccid3.ko even when
> not using ccid3 fully. Conceptually it is better to have a
> dccp_ccid3_lib.ko kernel module like we have now for the tfrc equation
> and loss interval code, dccp_tfrc_lib.ko. ccid3.ko and
> ccid4.ko would require dccp_ccid3_lib.ko.
>

OK

> > > This way you are still sharing code but it is clear CCID4 is based on CCID3.
>
> The scheme I propose also keeps this property.
>
> > Exactly! I was thinking about this since my first patchset sent via an
> > URL, where I commented about this. The problem of doing like you
> > suggested (move some code from ccid3.c to ccid3.h) is it will require
> > an approval about you and the others, such as gerrit and arnaldo, at
> > least if this is the right process to follow.
>
> Don't worry too much about "approvals" at this stage, I think you should
> do as you think its ok and discuss here mostly aspects of protocol
> implementation, i.e. compliancy with the RFCs, etc.
>
> Reorganizing the resulting source code to match Linux kernel guidelines
> is something we should try to do from the start, but also should not get
> in the way of having code that works first.
>

Nice to know this.

> > Anyway, I'm already identifying the candidate codes to be shared
> > between ccid3 and ccid4 if you didn't this yet. Another option is wait
> > for gerrit suggestion on this issue and discuss more about that and
> > define a strategy to avoid code repetition.
>
> See? Wait for Gerrit, wait for Arnaldo, reach a consensus on code layout
> first... nah, get something that works, when and if people send
> suggestions you react, but don't get lack of feedback on these matters
> to make you stop coding.
>

Ok, I'll try to always discuss with you about my work on the ccid-4
implementation.

> - Arnaldo
>

Leandro
