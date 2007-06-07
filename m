From: Florian Westphal <fw@strlen.de>
Date: Thu, 07 Jun 2007 22:18:16 +0000
Subject: Re: 'BUG: scheduling while atomic' during dccp transfer
Message-Id: <20070607221816.GC32086@Chamillionaire.breakpoint.cc>
List-Id: <dccp.vger.kernel.org>
References: <20070607194353.GA32086@Chamillionaire.breakpoint.cc>
In-Reply-To: <20070607194353.GA32086@Chamillionaire.breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo Carvalho de Melo <acme@ghostprotocols.net> wrote:
> On 6/7/07, Florian Westphal <fw@strlen.de> wrote:
> >> Can you try with the attached patch?
> >
> >I haven't been able to reproduce it so far.
> 
> You mean with this patch applied?

Yes, sorry for not being precise. I applied your
patch and so far I haven't seen this bug again.

Thanks,
	Florian
