From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 26 Nov 2006 18:38:47 +0000
Subject: Re: [PATCH 3/10]: Resolve small FIXME
Message-Id: <39e6f6c70611261038g5c57ab5dh258c9462400de813@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.26817@strip-the-willow>
In-Reply-To: <200611241619.26817@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/24/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Resolve small FIXME
>
> This considers the  case - ACK received while no packet has been sent
> so far. Resolved by printing a (rate-limited) warning message.
>
> Further removes an unnecessary BUG_ON in ccid3_hc_tx_packet_recv,
> received feedback on a terminating connection is simply ignored.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Thanks, applied.

- Arnaldo
