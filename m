From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 26 Nov 2006 19:05:47 +0000
Subject: Re: [PATCH 6/10]: Consolidate handling of t_RTO
Message-Id: <39e6f6c70611261105s557df473i26da0d028904b782@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.48635@strip-the-willow>
In-Reply-To: <200611241619.48635@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/24/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3] Consolidate handling of t_RTO
>
> This patch
>  * removes setting t_RTO in ccid3_hc_tx_init (per [RFC 3448, 4.2], t_RTO is
>    undefined until feedback has been received);
>
>  * makes some trivial changes (updates of comments);
>
>  * performs a small optimisation by exploiting that the feedback timeout
>    uses the value of t_ipi. The way it is done is safe, because the timeouts
>    appear after the changes to t_ipi, ensuring that up-to-date values are used;
>
>  * in ccid3_hc_tx_packet_recv, moves the t_rto statement closer to the calculation
>    of the next_tmout. This makes the code clearer to read and is also safe, since
>    t_rto is not updated until the next call of ccid3_hc_tx_packet_recv, and is not
>    read by the functions called via ccid_wait_for_ccid();
>
>  * removes a `max' statement in sk_reset_timer, this is not needed since the timeout
>    value is always greater than 1E6 microseconds.
>
>  * adds `XXX'es to highlight that currently the nofeedback timer is set
>    in a non-standard way
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Looks good, thanks, applied.

- Arnaldo
