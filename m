From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Wed, 15 Nov 2006 18:44:28 +0000
Subject: Re: [RFC] [PATCH]: use explicit enums for CCID 3 states
Message-Id: <39e6f6c70611151044g27059510v900407904a07bfef@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611151401.41404@strip-the-willow>
In-Reply-To: <200611151401.41404@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Hi Arnaldo
> |  Well, I'd rather prefer a WARN_ON type, probably rate limiting the
> |  printks, so that we can receive reports that something is fishy but
> |  don't panic the machine.
>
> I have implemented such a macro and have changed the patch to use it.
> If it is acceptable, I would like to propose it for general use.
>
> Just as I was checking the patch again, Ian's answer arrived -- now I
> understand why dump_stack() is used and WARN_ON preferred; the macros
> support this use.

I think something like WARN(), counterpart to BUG() is very much in demand :)

> Also implemented the enum bit fields suggestion by Eddie. It compiles
> fine on gcc 4.0.4; however, I am not sure about portability.
> And I don't have your tool either :-(

My DWARF tools have been always available at:

http://www.kernel.org/git/?p=linux/kernel/git/acme/pahole.git;a=summary

> The following is the revised patch with three macros added, I liked the
> DCCP_BUG_ON():

will look into that barring social life that is taking me so much time
that I should be working on DCCP :-P :-) Well, at least its not "Real
Work (tm)" :-)

- Arnaldo
