From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Thu, 09 Mar 2006 01:41:02 +0000
Subject: Re: [BUG] Performance issues if DCCP packets are routed
Message-Id: <cbec11ac0603081741k51b1436dqd657f35e08085f85@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0603081740o2004650dr8a91de3dd9418189@mail.gmail.com>
In-Reply-To: <cbec11ac0603081740o2004650dr8a91de3dd9418189@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

What I neglected to say is that TCP works fine and it is very low latency...

On 3/9/06, Ian McDonald <imcdnzl@gmail.com> wrote:
> I've been testing DCCP using netem for quite a while now - just about
> always with loss and delay. This works really well.
>
> A few weeks ago I noticed that if netem isn't turned on but traffic
> still goes between boxes through a router the performance is abysmal -
> can be as low as 20K per second instead of 100 Mbit and there is much
> data loss.
>
> I had assumed that this was a recent regression so parked it until I
> had time to test. However I just tested with a clean 2.6.14 and the
> problem persists....
>
> The test setup is
>
> 10.0.1.31 ----- 10.0.1.33/10.0.2.33 ------- 10.0.2.32
>
> and the command is just:
> (from 10.0.1.31) ./ttcp_acme -c -l500 -n10000 -t 10.0.2.32
> and
> (from 10.0.2.32) ./ttcp_acme -c -l500 -n10000 -r
>
> the following setup works fine:
> 10.0.1.31 ----- 10.0.1.33
> ./ttcp_acme -c -l500 -n10000 -t 10.0.1.33
> and
> ./ttcp_acme -c -l500 -n10000 -r
>
> I'll add this to my list of bugs to look at at some stage (along with
> updating tx buffering, CCID2 not working with loss/delay) but
> interested in seeing if others have similar problems?
>
> Ian
> --
> Ian McDonald
> Web: http://wand.net.nz/~iam4
> Blog: http://imcdnzl.blogspot.com
> WAND Network Research Group
> Department of Computer Science
> University of Waikato
> New Zealand
>


--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
