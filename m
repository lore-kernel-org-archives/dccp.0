From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 15 Feb 2006 12:31:37 +0000
Subject: Re: [PATCH 1/1]: [CCID2]: Fix the use of the RTO timer
Message-Id: <39e6f6c70602150431r6e58825ybf8ea6dc8b6b7de0@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060215013015.GA14878@tribal.sorbonet.org>
In-Reply-To: <20060215013015.GA14878@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/14/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> Drop sock reference count on timer expiration and reset.
>
> There was a hybrid use of standard timers and sk_timers.  This caused the
> reference count of the sock to be incorrect when resetting the RTO timer.  The
> sock reference count should now be correct, enabling its destruction, and
> allowing the DCCP module to be unloaded.

Thanks, applied and pushed to Dave, I wonder why I didn't catched this...

- Arnaldo
