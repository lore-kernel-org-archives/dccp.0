From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Thu, 30 Nov 2006 00:46:12 +0000
Subject: Re: [PATCH] [RFC]: Fine-grained sending rate resolution / division errors
Message-Id: <39e6f6c70611291646y51dfea8fmf210c475f0b23670@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611292052.01303@strip-the-willow>
In-Reply-To: <200611292052.01303@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Here is now the patch, I have had a hard time due to division of u64 by
> u32. I have also checked again - it is feasible to prune X_calc and
> X_recv back to u32. If you prefer that, I can change the patch.

If it is possible, its better, minus 8 bytes per half connection on a
(hey, I really, really wanna see this real) _real busy_ DCCP server
:-)

> I'd welcome suggestions about how to improve the division, I had wanted
> to at least not throw away the remainder.

Just got back from a "my dog took me to do some exercise" session,
will have to read this tomorrow again, but I liked what I saw from the
first skim of it :-)

- Arnaldo
