From: Ian McDonald <ian.mcdonald@jandi.co.uk>
Date: Mon, 02 Aug 2010 09:19:15 +0000
Subject: Re: Problems with idle DCCP connections
Message-Id: <AANLkTikFWJN2tPeYNP5H6cLDJ15c7cDc4nVnf762zDsJ@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
In-Reply-To: <1280524030.9374.108.camel@sjerolaptop.homelinux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Samuel,

My main comment about DCCP in Linux is that it is still very
experimental. There is a lot of good work gone into it, but there are
also still some problems.

I used it for my research also (see my website and click on research)
and did quite a bit to get it working for me but I largely used CCID3
and fixed up aspects of that and got code merged for that. I would
encourage you to have a go at seeing if you can fix it (provided
no-one else does first!) as this will help you in your future research
if you are able to work on this aspect.

Best regards

Ian
--
twitter imcdnzl
web http://www.next-genit.co.uk



On 30 July 2010 22:07, Samuel Jero <sj323707@ohio.edu> wrote:
>
> Hello All,
>
> I am a researcher at Ohio University looking to encapsulate a special
> point-to-point Delay Tolerant Networking protocol in DCCP instead of UDP
> to take advantage of DCCP's congestion control.
>
> In attempting to set this up I have come across some very odd behavior
> from DCCP. My goal is to open one DCCP connection and then keep it open
> even when the encapsulated protocol is idle (this avoids having a
> three-way handshake for every packet sent). However, in my tests, DCCP
> clamps the sending rate down to three packets per second after a short
> idle period (a few seconds) and then never attempts to increase that
> rate. This seems to be a very unusual and counter-intuitive behavior.
> Has anyone else seen similar behavior? This seems to contradict RFC4341
> section 5.1 which says that CCID2 should slow start after an idle
> period. Is this not implemented yet or is it a bug?
>
> My test machines are running Ubuntu 10.04. Uname -a
> "2.6.32-24-generic-pae #38-Ubuntu SMP Mon Jul 5 10:54:21 UTC 2010 i686
> GNU/Linux". I have seen identical behavior with Ubuntu 9.10 (Linux
> 2.6.31). I'm using CCID2 "TCP-like Congestion control" since I want as
> much bandwidth as possible, even if that means rapid fluctuations.
>
> Thanks.
>
> Sincerely,
> Samuel Jero
>
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
