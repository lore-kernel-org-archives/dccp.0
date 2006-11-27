From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Mon, 27 Nov 2006 18:34:41 +0000
Subject: Re: [PATCH 1/6]: Fix bug in calculation of first t_nom and first t_ipi
Message-Id: <39e6f6c70611271034o6b1db4c9o30cabafc5c5d2c2f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.07412@strip-the-willow>
In-Reply-To: <200611211545.07412@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/27/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> > Therefore, let me put it very clearly: I am against implementing anything which is not stated in
> > RFCs 3448, RFC 4340, RFC 4341, and RFC 4342. About the rest we might talk when the Linux implementation
> > matches these RFCs, but before we have accomplished that: please stop sending feature requests or
> > annotations which are not part of the publicly and IETF-approved RFCs. For these purposes, please
> > use dccp@ietf instead.
>
> I will throw in my opinion here. Linux is about experimenting with
> ideas in many cases - that is the joy of it. People can and should
> contribute whatever they want. They shouldn't be constrained by
> anything.

Agreed, and we've worked really hard in the last years for Linux to be
a testbed for new ideas, look no further than the pluggable TCP
congestion control and the DCCP CCID pluggable infrastructures, that
we dream of unifying one day (look at
http://darkircop.org/dccp/tcp/ to see Andrea's experimentation making
DCCP use all the TCP congestion control algorithms).

> Eddie can suggest whatever he likes and I welcome it. That doesn't
> mean it will get included though as it depends on coders. You don't
> like his approach which is fine - it means that you won't code it. I
> like the sounds of it but very time constrained so probably won't
> unless it helps me solve a problem in my PhD. But someone else who is
> motivated might go and do it.

And as I said, go for it! If it needs changes on how the core
interacts with CCIDs, I'd love to hear, I just understand Gerrit's
worries as we all need a standards compliant DCCP implementation as a
much longed for milestone.

> Linux isn't always RFC compliant either - ask Sally for example about
> TCP.... (Although Linux is probably better than any other OS in RFC
> compliance).

Its just great that the RFC authors are taking part on the discussion,
that way things like this are noticed and provide clues for further
work on erratums and updates to the RFCs, we just don't want to trow
all the effort they have put in writing the RFCs by not following it
8-)

> > I am sure we can work out a constructive way of dealing with your interests as well, but it is certainly
> > not via the avenue of implementing feature requests which you state without contributing in work or in
> > funding.
> >
> I agree that the main focus of Linux is "show me the code" and for
> this to go in someone has to code. I also value Eddie making comments
> and hope it continues.

Heck, I was commenting with David Miller, Linux has come a long way,
now the RFC authors are reviewing Linux kernel code, that is
absolutely awesome and I sincerely _beg_ for this to continue :-)

- Arnaldo
