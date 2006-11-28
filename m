From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Nov 2006 20:27:24 +0000
Subject: Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <20061128202723.GF19882@mandriva.com>
List-Id: <dccp.vger.kernel.org>
References: <200611281435.05466@strip-the-willow>
In-Reply-To: <200611281435.05466@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Nov 29, 2006 at 09:17:04AM +1300, Ian McDonald wrote:
> On 11/29/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> >Quoting Ian McDonald:
> >|  I think I didn't explain my point well here. You can't change to u32
> >|  but need to be unsigned int (not u64).
> >Don't get this: u32 is a 32-bit unsigned value and therefore looks 
> >sufficient - and you
> >are proposing `unsigned int' to have easier conversion to skb->len, right?
> >
> OK. On 64 bit platform unsigned int = 64 bits and we are passing a 64
> bit argument (skb->len) into a 32 bit parameter. We either need to
> explicitly typecast or change wherever you have put u32 to unsigned
> int.
> 
> Arnaldo probably knows which way is better from his experience.

Just make it unsigned int, matching skb->len

- Arnaldo
