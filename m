From: Ian McDonald <imcdnzl@gmail.com>
Date: Thu, 16 Feb 2006 02:56:34 +0000
Subject: Re: [RFC] CCID infrastructure improvements
Message-Id: <cbec11ac0602151856k306a7cbdl17b75b98c7d0b7b4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70602151022v2d63a9d3nf88c0db59bfa36e9@mail.gmail.com>
In-Reply-To: <39e6f6c70602151022v2d63a9d3nf88c0db59bfa36e9@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>
> I tested with the code that is in the "ccid_operations" of my
> net-2.6.17 git tree (can
> you give it a try? Perhaps I did some last minute fix over the one you tested),
> but without a middle box, tomorrow I'll revive this parisc and use
> another machine
> to test on real machines, not just qemu.
>
Just doing more testing and the bug goes quite a while back - not sure
when last good version was. If time permits I'll test further using
git-bisect. It  is fine when run on two machines talking directly
without loss/latency - only breaks on netem....
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
