From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 04 Feb 2012 16:03:41 +0000
Subject: Re: Bug on CCID 3 of DCCP
Message-Id: <20120204160341.GA6756@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
In-Reply-To: <CAG_KctrYctZVKLbhNhWv00ZYLwn0RZRtb_-4aQQDtrsfHGMivQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Jordi,

2.6.35.4 was announced 26 August 2010, almost 1.5 years ago. Since then
some more CCID-3 specific changes have been committed, but there are 
still some significant changes in the 'test tree' which you can get
from
	git://eden-feed.erg.abdn.ac.uk/dccp_exp

using subtree 'dccp' or 'ccid5' (which includes CCID-3, CCID-4, an
experimental CCID-0 without congestion control and an experimental
CCID-5 variant of CCID-2 using TCP cubic). The experimental variants
aside, the test tree has seen more development and prolonged testing.

Since it has happened several times in the past that bugs which showed up
in the mainline could not be reproduced with the test tree, can you please
first see if the bug re-appears with the test tree?

There are two ways of doing this

 1. git, details are on
    http://www.linuxfoundation.org/collaborate/workgroups/networking/dccptesting#Experimental_DCCP_source_tree

 2. a patched tarball or patches 
    These are provided on the same webserver as the above git:// url,
    tarball and patches are generated at least once weekly from the 
    latest net tree by David Miller.

If the problem does persist with the test tree, I will take care of working on the issue and ask for more
input to reproduce the problem.

If the problem does not persist with the test tree, I will make an effort to get the test tree patches
submitted soon.

Gerrit

Quoting Jordi Salvador:
| Hello:
| 
| First of alsl, thank you for your quick answer. The kernel we are using
| is 2.6.35.4 (and 2.6.35.14, since a few days ago). We haven't tried
| Gerrit's development code, yet.
| 
| I tried to read the code and understand it, and I also read the
| relevant RFCs (for example, 4342 and 5348, and also the draft
| specified in the source code), and I haven't yet been able to
| understand why that situation arises. We have not much experience with
| the Linux kernel source code.
| 
| Thanks again for your answer.
| 
| On 2 February 2012 17:38, Ian McDonald <ian.mcdonald@jandi.co.uk> wrote:
| > Hi Jordi
| >
| > I am not actively working on this code at present so sending to
| > dccp@vger.kernel.org.
| >
| > You will get asked a few questions so will ask them to you now:
| > - what version of kernel are you using?
| > - have you tried Gerrit's development code?
| >
| > The other thing with an experimental area of the Linux kernel is that
| > if you are lucky someone will respond, otherwise you might need to
| > learn the code and try and fix yourself. If you do not wish to do this
| > you might wish to engage a professional firm. I went and fixed much of
| > the code because I had problems I needed to resolve, for example.
| >
| > If I do get time then I may look at it, but highly unlikely I am afraid.
| >
| > Regards
| >
| > Ian
| >
| > On 2 February 2012 15:48, Jordi Salvador <salvador@wingsformedia.com> wrote:
| >>
| >> Hello Mr. McDonald:
| >>
| >> We are developing an application on Linux which sends data using the
| >> DCCP protocol with CCID 3. Sometimes, while sending data, we get a bug
| >> message, originated in net/dccp/ccids/ccid3.c, line 240, and then the
| >> system freezes. Looking at the kernel source code we find the
| >> following:
| >>
| >> BUG_ON(hc->tx_p && !hc->tx_x_calc);
| >>
| >> We haven't been able to reproduce that bug (it just happens randomly),
| >> and we don't exactly understand the meaning of the condition that
| >> triggers the bug, nor how that condition may hold true. Could you
| >> point out us some ideas which could help us to understand why we are
| >> experiencing that bug and to understand its meaning?
| >>
| >> Thank you in advance.
| >> --
| >> Jordi Salvador
| >> +34934980980
| >> +34660842146
| >> salvador@wingsformedia.com
| >>
| >> Warning: This e-mail is privileged, confidential and contains private
| >> information. Any reading, retention, distribution or copying of this
| >> communication by any person other than its intended recipient is
| >> prohibited.
| 
| 
| 
| -- 
| Jordi Salvador
| +34934980980
| +34660842146
| salvador@wingsformedia.com
| 
| Warning: This e-mail is privileged, confidential and contains private
| information. Any reading, retention, distribution or copying of this
| communication by any person other than its intended recipient is
| prohibited.
| --
| To unsubscribe from this list: send the line "unsubscribe dccp" in
| the body of a message to majordomo@vger.kernel.org
| More majordomo info at  http://vger.kernel.org/majordomo-info.html
| 

-- 
