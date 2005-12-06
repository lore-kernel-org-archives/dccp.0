From: Ian McDonald <imcdnzl@gmail.com>
Date: Tue, 06 Dec 2005 19:29:27 +0000
Subject: Re: initial CCID2 implementation for linux
Message-Id: <cbec11ac0512061129x92a3810w25689ef74f70bc2b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20051206190131.GA834@tribal.sorbonet.org>
In-Reply-To: <20051206190131.GA834@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/7/05, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> http://darkircop.org/acme-ccid2-20051206.diff

Can't access that host - appears to be no DNS record.
>
> it's a diff from today's:
> git/acme/net-2.6.16.git
>
> To use it, you need to compile support for ack vectors and:
> setsockopt DCCP_SOCKOPT_CCID_RX and DCCP_SOCKOPT_CCID_TX to 2.

If you play around with Kconfig files you should be able to get ack
vectors automatically turned on when selecting this.

> Any feedback is appreciated.  Specifically, if this code looks "promising" [i.e.
> eventually commitable], it would be nice if someone can indicate the major
> problems with it. [coding style, way of doing things, bugs, etc]
>
It sounds great!! I will look at it when I can get to the website and
time permits (just returned from honeymoon!)

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand
