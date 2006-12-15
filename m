From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 15 Dec 2006 23:59:15 +0000
Subject: Re: [PATCH 0/8]: Sequence numbers, larger windows revisited, minor cleanups
Message-Id: <39e6f6c70612151559g2aa97959w218af74eaa39644e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612151049.50073@strip-the-willow>
In-Reply-To: <200612151049.50073@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/15/06, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
> On 12/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > This is a small set of patches, likely the last for this year.
> > I have run my whitespace test script over them and gave them a
> > test run (sorry, the sparc64 is not yet up).
> >
> These look good. I presume that they are unfortunately 2.6.21 material
> now :-( At least Gerrit has them as a patch set up. I'll go rework my
> other patches now when I get a chance.
>
> The only change (at present) I know that hasn't made it up to Dave M
> for 2.6.20 would be this trivial one of mine:
> http://www.mail-archive.com/dccp@vger.kernel.org/msg01150.html
>
> I presume this will get pushed to him at some stage.

Well, I guess it doesn't matter at what stage things are submitted for
inclusion as long as the proposed changes are pure bugfixes, and as
DCCP is in such a experimental stage it may well be the case that
Gerrit's changes can be classified as such and submitted for 2.6.20.

Tomorrow I'll try to review this patch series and take into account
your opinion when deciding which ones are pure bug fixes worthy for
pushing to DaveM and then to Linus.

Thanks a lot for your work.

- Arnaldo
