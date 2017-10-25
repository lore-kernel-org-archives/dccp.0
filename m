From: David Miller <davem@davemloft.net>
Date: Wed, 25 Oct 2017 03:59:33 +0000
Subject: Re: [PATCH] net: dccp: Convert timers to use timer_setup()
Message-Id: <20171025.125933.1786953066924623254.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20171024084609.GA23862@beast>
In-Reply-To: <20171024084609.GA23862@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 01:46:09 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly. Adds a pointer back to the sock.
> 
> Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: dccp@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
