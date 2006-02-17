From: Ian McDonald <imcdnzl@gmail.com>
Date: Fri, 17 Feb 2006 01:19:12 +0000
Subject: Re: panic in ccid3_hc_rx_packet_recv
Message-Id: <cbec11ac0602161719k2f1f162cw7b47097b6148d24f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70602160833j3973cf98xb21dde79da42ac78@mail.gmail.com>
In-Reply-To: <39e6f6c70602160833j3973cf98xb21dde79da42ac78@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/17/06, Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> Long session over a wi-fi link, tons of packets already transmitted
> then this panic, Ian,
> can you take a look? There are two divisions in ccid3_hc_rx_packet_recv...
>
OK. Just had a quick look at it. Must be the second one as first is
divided by an integer so no chance of divide by zero. Will look at it
more later.

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
