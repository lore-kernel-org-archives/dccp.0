From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 12 Dec 2005 14:34:16 +0000
Subject: Re: [PATCH] tcp: make reno default for mortals
Message-Id: <39e6f6c70512120634h5119b014m74a6c42d41d0e925@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/12/05, David S. Miller <davem@davemloft.net> wrote:
> From: "David S. Miller" <davem@davemloft.net>
> Date: Tue, 06 Dec 2005 21:08:27 -0800 (PST)
>
> > Then we shouldn't be changing BIC, but instead make a new
> > tcp_cubic.c :-)
>
> As I mentioned in my net-2.6.16 rebase posting tonight,
> I took care of this.

Great, soon the DCCP club band (growing, whee!) will join the
anti-congestion brigade and add another algo to the tree, CCID2,
TCP-Like congestion control for DCCP, courtesy of Andrea Bittau, the
DCCPer of the month </McDonalds> :-)

- Arnaldo (happy clown 8-) )
