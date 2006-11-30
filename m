From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Nov 2006 19:24:23 +0000
Subject: Re: [PATCH] [RFC]: Fine-grained sending rate resolution / division errors
Message-Id: <200611301924.23535@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611292052.01303@strip-the-willow>
In-Reply-To: <200611292052.01303@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  > Here is now the patch, I have had a hard time due to division of u64 by
|  > u32. I have also checked again - it is feasible to prune X_calc and
|  > X_recv back to u32. If you prefer that, I can change the patch.
|  
|  If it is possible, its better, minus 8 bytes per half connection
I have checked again - the best that seems possible is 4 bytes less. This 
is due to X_recv which acts as cache in [RFC 3448, 4.4] - lots of division
operations where the value needs to be stored afterwards again.
So X_calc would remain as 32bit, I will write up how I think it should look
like and revise the patch - tomorrow, since the bug hunting took some time
away.

Ian I am sorry for the time lost in bisecting through the patches. There are
however more issues to resolve where your help and advice will be sorely needed.
With this bug I felt somehow responsible since in a way I had caused it.

Gerrit
