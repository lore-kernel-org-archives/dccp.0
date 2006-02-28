From: "Ian McDonald" <imcdnzl@gmail.com>
Date: Tue, 28 Feb 2006 21:35:05 +0000
Subject: Re: Resend: [PATCH] DCCP: Divide by zero fix
Message-Id: <cbec11ac0602281335n3c53c214mc2e8fb4d4e104c9e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0602281324i6e1ff681m752c06c3b7fa7b97@mail.gmail.com>
In-Reply-To: <cbec11ac0602281324i6e1ff681m752c06c3b7fa7b97@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/1/06, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> On 2/28/06, Ian McDonald <imcdnzl@gmail.com> wrote:
> > Arnaldo,
> >
> > Haven't seen this going in so resending...
>
> What a coincidence, I'm testing this patch right now, and I'm afraid it has
> some bug or makes it more likely that some other bug happens, the machine
> soft locks with it enabled and when using CCID3 as the default RX CCID in
> a TTCP test over loopback.
>
> Note that the problem happens more quickly if you test it on a machine with
> less than 64 MB (where the problem happens, but after more time).
>
OK. I am doing some testing on lockups at present from CCID3 which I
suspect are introduced recently.... they don't lock up on older code.
Having said that I'm running without that patch applied so I will
retest soon - but I don't believe it is the problem when I looked at
the scope of that code.

I have a suspicion that if I don't find anything with git-bisect for
CCID3 lockups that it might be when you use CCID3 and set
DCCP_INITIAL_SEND_ACK_VECTOR to 1....

Anyway another 3 or 4 reboots and I should give some more answers.

BTW my problems occur when using a netem box in the middle as per
setup described on DCCP testing on ODSL Wiki.

Ian
--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
