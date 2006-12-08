From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Fri, 08 Dec 2006 12:56:18 +0000
Subject: Re: [Patchv2 4/12]: Deprecate ccid3_hc_tx_insert_options
Message-Id: <39e6f6c70612080456k3b5bc1d5v14c31dc8e031204@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612081150.06793@strip-the-willow>
In-Reply-To: <200612081150.06793@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/8/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> | > [CCID 3]: In-line ccid3_hc_tx_insert_options
> <snip, quoting Ian: >
> |  A couple of points here:
> |  - the whole ccid3_hc_tx_insert_options could actually be removed with
> |  a little work as there is no ccid2 equivalent and so the whole thing
> |  isn't needed!

> Many thanks for this information.
> I currently hesitate to remove it from the CCID interface, it may be that we can
> make use of it later

Then we get it back, the ccid infrastructure was modelled after the
existing CCID3 code from Waikato/Lulea, you're now doing a mucho
needed review of all this code, so if you think its a good idea to
remove things that are not used by CCID2 and CCID3, so lets do it, in
the kernel we don't promise stable APIs, so its not like some out of
the tree ccid module would break if we remove this and so we should
avoid it.

If in the future CCID9 needs a hook for this, we add it in the
infrastructure, no need to overengineer right now, agreed?

- Arnaldo
