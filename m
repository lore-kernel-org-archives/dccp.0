From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 22:16:43 +0000
Subject: Re: About pluggable congestion control infrastructure in DCCP
Message-Id: <20070819221643.GB24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <e3c7f9e80708190627y3e883241gb1def650e37965c0@mail.gmail.com>
In-Reply-To: <e3c7f9e80708190627y3e883241gb1def650e37965c0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Aug 20, 2007 at 08:53:15AM +1200, Ian McDonald escreveu:
> On 8/20/07, Shahiduzzaman <shahid21st@gmail.com> wrote:
> > Hi all,
> >
> > This may be a redundant or very naive question - sorry in advance for
> > that. Can anybody tell me, whether the current Linux kernel DCCP
> > implementation is done in a fashion like TCP pluggable congestion
> > avoidance modules infrastructure (http://lwn.net/Articles/128681/) ?
> 
> The short answer is yes and no!

I think the answer is just "yes"

The CCID infrastructure in the Linux kernel is done in a fashion like
the TCP pluggable congestion avoidances modules infrastructure. One can
write a new CCID and load, making it available for userspace programs to
use without changing a line of code in what is already in the kernel.
 
> No that the in-tree version does not support it.
> 
> Yes in that for CCID2 (TCP like) there was an out of tree version that
> could use the different TCP congestion control methods.

The question was if it was done "in a fashion like", not "exactly as". I
may be confused with your answer as english is not my first language tho
:-)

> If you mean a simple way to plug in new CCIDs like CCID4 etc then the
> answer is no. However two people are working on CCID4 which may make
> the code more modular.

Why not? See the recent implementation of CCID0 (UDP Like Congestion
Control :-)) by Gerrit:

http://www.mail-archive.com/dccp@vger.kernel.org/msg02091.html

Of course, as in the current TCP pluggable infrastructure it may well be
the case that the current CCID pluggable infrastructure something that
a new CCID wants to plug into is not pluggable yet.

- Arnaldo
