From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 01 Dec 2006 14:36:06 +0000
Subject: Re: [PATCHv3] [DCCP]: Use higher timeout value for nofeedback timer
Message-Id: <39e6f6c70612010636i292957e6q1bd71e0855e968f6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612011429.21131@strip-the-willow>
In-Reply-To: <200612011429.21131@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/1/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This is version three of the patch to increase the minimum
> bound of the nofeedback timer. It now features
>  * millisecond granularity for increased testing comfort
>  * a more informative configuration menu
>
> This patch is against the very latest tree by acme-2.6.20
>
> ===> For testing against 2.6.19 one would need to use
>         a value of 1000 since this was the default in 2.6.19
>         calculation of nofeedback timeout.
>
> ----------------------> Patchv3 <---------------------------
> [DCCP]: Use higher RTO default for CCID3
>
> The TFRC nofeedback timer normally expires after the maximum of 4
> RTTs and twice the current send interval (RFC 3448, 4.3). On LANs
> with a small RTT this can mean a high processing load and reduced
> performance, since then the nofeedback timer is triggered very
> frequently. As a result, the sending rate quickly converges towards
> zero.
>
> This patch provides a configuration option to set the bound for the
> nofeedback timer, using as default the TCP lower bound of 1 second.
>
> By setting the configuration option to 0, strict RFC 3448 behaviour
> can be enforced for the nofeedback timer.

Looks ok, you just forgot to update the commit log message, the
default is not anymore 1 second, its 100ms :-)

- Arnaldo
