From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Thu, 30 Nov 2006 19:37:49 +0000
Subject: Re: [PATCH] [RFC]: Fine-grained sending rate resolution / division errors
Message-Id: <39e6f6c70611301137u7570f919v5b7e27424c8b5313@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611292052.01303@strip-the-willow>
In-Reply-To: <200611292052.01303@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/30/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Quoting Arnaldo Carvalho de Melo:
> |  > Here is now the patch, I have had a hard time due to division of u64 by
> |  > u32. I have also checked again - it is feasible to prune X_calc and
> |  > X_recv back to u32. If you prefer that, I can change the patch.
> |
> |  If it is possible, its better, minus 8 bytes per half connection
> I have checked again - the best that seems possible is 4 bytes less. This
> is due to X_recv which acts as cache in [RFC 3448, 4.4] - lots of division
> operations where the value needs to be stored afterwards again.
> So X_calc would remain as 32bit, I will write up how I think it should look
> like and revise the patch - tomorrow, since the bug hunting took some time
> away.

OK, take your time.

>
> Ian I am sorry for the time lost in bisecting through the patches. There are
> however more issues to resolve where your help and advice will be sorely
needed.

s/sorely/surely/g

<joke>
No need to inflict pain on Ian, not at this level!
</joke>

:o)
