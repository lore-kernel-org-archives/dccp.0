From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 03 Oct 2006 18:15:17 +0000
Subject: Re: [dccp] Packet size s on CCID3
Message-Id: <5640c7e00610031115w629b5bc9p1baa33ab1bd138e1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
In-Reply-To: <5640c7e00609202022j1b97cf1g30797ffcd9b650b6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/4/06, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> The answer of course is that you DON'T have to assume that s=MSS here, you can
> use the real packet size.  So am I missing something in your question?

Yes. See below.
>
> If s cancels out (bc you are designing a packets/sec implementation), then it
> doesn't matter what s is.  Set it to MSS, set it to 1, who cares?  The
> packet/sec rate you get out of the throughput equation will be the same, no?
>
As I read RFC4342 I can't implement a packets per second
implementation directly - there are several options but packets per
second is not one of them. The mathematical equation allows it as you
seem to agree by your first statement. The RFC doesn't. If we track
the average packet size it works but then that is a whole lot more
complex code to achieve exactly the same thing.

> Eddie

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
