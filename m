From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Wed, 29 Nov 2006 16:03:29 +0000
Subject: Re: CCID 3: Strategy for removing division bugs and division errors
Message-Id: <39e6f6c70611290803v58b2171dx459bb6b3be33f3e5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611291515.46613@strip-the-willow>
In-Reply-To: <200611291515.46613@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> As promised, I sat down and wrote up conditions and current problems with
> some of the calculations in the CCID 3 module. Changes are required only for the sender.
>
> In a nutshell, the strategy solves
>  * the problem that dividing-by-seconds is not handled correctly
>  * defines a sufficient resolution for tracking sending rates
>  * gets rid of the overflow problem
>
> The cost is that
>  * at least 1 and ideally 3 structure elements of tfrc_tx_info make it to __u64
>  ==> Arnaldo are you OK with this?

first_read() = 0; /* No problems */
rereading() ....
