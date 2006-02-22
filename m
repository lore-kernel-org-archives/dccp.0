From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Wed, 22 Feb 2006 00:49:14 +0000
Subject: Re: [PATCH 1/1][DCCP]: sparse endianness annotations
Message-Id: <39e6f6c70602211649n62332939wbadd5ef527453a4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70602211630m52d57c43m5365835ebad48e0@mail.gmail.com>
In-Reply-To: <39e6f6c70602211630m52d57c43m5365835ebad48e0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/21/06, David S. Miller <davem@davemloft.net> wrote:
> From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
> Date: Tue, 21 Feb 2006 21:30:15 -0300
>
> >    Please consider pulling from:
> >
> > master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.17.git
>
> Pulled, thanks a lot.
>
> So are you using branches or not? :-)))

Do you prefer? Today I talked with our git guy (Eduardo Habkost) and
changed my mind, doing things (duh!) in "master" and using git-fetch/
git-rebase to track your net-2.6.17 tree seems less noisy on Linus
git log history :-)

- Arnaldo
