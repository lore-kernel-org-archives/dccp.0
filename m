From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 28 Feb 2006 21:28:48 +0000
Subject: Re: Resend: [PATCH] DCCP: Divide by zero fix
Message-Id: <39e6f6c70602281328n4c8a99av694b4a85ebb9f894@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <cbec11ac0602281324i6e1ff681m752c06c3b7fa7b97@mail.gmail.com>
In-Reply-To: <cbec11ac0602281324i6e1ff681m752c06c3b7fa7b97@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/28/06, Ian McDonald <imcdnzl@gmail.com> wrote:
> Arnaldo,
>
> Haven't seen this going in so resending...

What a coincidence, I'm testing this patch right now, and I'm afraid it has
some bug or makes it more likely that some other bug happens, the machine
soft locks with it enabled and when using CCID3 as the default RX CCID in
a TTCP test over loopback.

Note that the problem happens more quickly if you test it on a machine with
less than 64 MB (where the problem happens, but after more time).

- Arnaldo
