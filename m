From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 26 Jun 2007 03:27:55 +0000
Subject: Re: DCCP performances
Message-Id: <5640c7e00706252027od3c379fkea903696d669ae7f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <fca78b970706050927k53a1107fr680a17a4d48b99e@mail.gmail.com>
In-Reply-To: <fca78b970706050927k53a1107fr680a17a4d48b99e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi there Patrick,

Sorry to take so long to reply.

As you correctly point out debugging and probing slow things down.
Unfortunately with any debugging tool there are side effects which
can, at times, render things useless - a bit like Schr=F6dinger's cat.

So use this for debugging when you need, or get a faster machine to
keep up with the debugging. My tendency for high speed bugs is to just
put in printk(KERN_CRIT "blah") into the code when I'm working on a
bug and only spit out the information I want and no other debugging.

Another tool that can be quite useful is to use tcpdump and then
analyse with WireShark (formerly Ethereal). I prefer to directly
capture using tcpdump first as less overhead.

Also in my testing I shut down all unnecessary services such as X,
apache, exim etc as these can have quite an impact on performance. The
biggest impact is if you're trying to use dccp_probe from a graphical
window as opposed to a console.

Anyway I'm rambling a bit and hope this is of some use.

Ian

On 6/6/07, Patrick Andrieux <patrick.andrieux@gmail.com> wrote:
> Hi again,
>
> Here is a description of another point I'd like to report. It's
> obvious if you think on it, but it's not if you don't.
> I ran some tests the last couple of days, and I was surprise by the
> bitrate iperf gave   me : at about 50kbits/sec... and I didn't
> understand why since last week. The problem was the debug messages
> printing.
>
> It takes lots of time to write in a file, and I enabled debug messages op=
tions.
> So, I can let you imagine my logs... 3Go at the end of the day...
> I disabled these options (in /etc/modprobe.d/networks)... the bitrate
> given by iperf is now about 2.3Mbits/sec.
>
> And I noticed the same "problem" using dccp_probe module only. It
> slows down the traffic at about 1.7Mbits/sec. It prints out less
> information so it makes sense to have a better birate than with debug
> messages enabled.
>
> So the point is all these values are wrong since their printing affect
> rate, RTT, loss, .... calculation.
>
> rgds,
> Patrick.
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


--=20
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
