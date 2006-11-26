From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 26 Nov 2006 18:42:50 +0000
Subject: Re: [PATCH 4/10]: Consolidate timer resets
Message-Id: <39e6f6c70611261042m56b0912fy32c6b46f397de8ed@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.34008@strip-the-willow>
In-Reply-To: <200611241619.34008@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/24/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Consolidate timer resets
>
> The specification in [RFC 3448, 4.4, step (3)] is impossible to
> implement: when no feedback has been received, the value of RTT
> is undefined as per [RFC 3448, 4.2]. Hence we can not set the
> timeout value to max(4*R, 2*s/X) as step (3) suggests.
>
> The most reasonable solution is to remain at the initial timeout
> value of 2 seconds, as per [RFC 3448, 4.2] - until an estimate
> for R has been computed.
>
> The patch also consolidates handling timer restart by adding
> an appropriate jump label and initialising the timeout value.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Thanks, applied.

- Arnaldo
