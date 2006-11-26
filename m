From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 26 Nov 2006 18:53:47 +0000
Subject: Re: [PATCH 5/10]: Consistently update t_nom, t_ipi, t_delta
Message-Id: <39e6f6c70611261053u50e9404em6fb53f4df1e7bfbb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611241619.41268@strip-the-willow>
In-Reply-To: <200611241619.41268@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/24/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3] Consistently update t_nom, t_ipi, t_delta
>
> This patch
>
>  * consolidates updating of parameters (t_nom, t_ipi, t_delta) which
>    need to be updated at the same time, since they are inter-dependent
>
>  * removes two inline functions which are no longer needed as a result of
>    the above consolidation
>
>  * resolves a FIXME regarding the re-calculation of t_ipi within the nofeedback
>    timer, in the state where no feedback has previously been received
>
>  * ties updating these parameters to updating the sending rate X, exploiting
>    that all three parameters in turn depend on X; and using a small optimisation
>    which can reduce the number of required instructions: only update the three
>    parameters when X really changes
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Looks good, applied,

- Arnaldo
