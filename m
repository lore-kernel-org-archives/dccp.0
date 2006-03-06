From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Mon, 06 Mar 2006 20:14:22 +0000
Subject: DCCP with iperf was Re: Question on iperf versions
Message-Id: <cbec11ac0603061214n5bf2e62fo1d807eef78d5f782@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/7/06, John S. Estabrook <jestabro@ncsa.uiuc.edu> wrote:
>
> Connie, 2.0.2 is the recommended version, which addresses several bugs in
> 2.0.1; the patch for 2.0.2, if you're refering to the one mentionied at
> the bottom of the iperf page, was submitted but is not necessary---it's a
> feature addition (re DCCP), not a bug fix.
>
I wondered who had also written an iperf patch for DCCP besides me and
I see that my code has been posted up there :-)

Just a note for those looking in future - the iperf works for Linux
2.6.14 but not on the latest development kernels. I will work on
fixing this at some point but if anybody feels brave I think it is
because of the introduction of service codes. It is also worth adding
multiple CCID support as well I believe...

I also intend to start merging some of the changes into the iperf
codebase over time (probably a long time with my current workload!).
Also this code was originally written by others and I've just tidied
it up a little bit.

Ian
--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
