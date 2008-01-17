From: "maillist ifiaas" <maillist.ifiaas@gmail.com>
Date: Thu, 17 Jan 2008 07:30:24 +0000
Subject: Re: CCID2 TCP Friendliness Test ?
Message-Id: <161d69110801162330v7468a23dncd037d023dcb7e1b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <161d69110801162017v658133a6j5920b06a3073d696@mail.gmail.com>
In-Reply-To: <161d69110801162017v658133a6j5920b06a3073d696@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thank you Ian.
If any one has report of such experiments, I don't need to do the same work.

gavin

On Jan 17, 2008 2:24 PM, Ian McDonald <ian.mcdonald@jandi.co.nz> wrote:
>
> On Jan 17, 2008 5:17 PM, maillist ifiaas <maillist.ifiaas@gmail.com> wrote:
> > Hi friends,,
> >
> > Where can we find CCID2 (latest Linux release) test against TCP ?
> > There seems no measurement study to validate the TCP friendliness on
> > any existing implementation yet, including BSD.
> >
> > Emmanuel Lochin has did some test before, showing the BSD
> > implementation was not very well:
> > http://manu.lochin.org/dccp/tests/dccp_eval.html
> >
> > Any similar test for Linux CCID2 out there?
> >
> > Thank you very much!
> >
> > gavin
>
> Easy enough to do a test with modified iperf. Gerrit and I both have
> patches for iperf to run it continuously, use dccp and select the TCP
> congestion mechanism - use Reno in particular.
>
> I used to do this with simultaneous CCID3 and TCP to see that they
> matched the rate, you could do the same for CCID2. You can use netem
> also to constrain link or introduce loss also.
>
> Regards
>
> Ian
> --
> Web: http://wand.net.nz/~iam4/
> Blog: http://iansblog.jandi.co.nz
>
