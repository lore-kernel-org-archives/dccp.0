From: David Miller <davem@davemloft.net>
Date: Fri, 09 Mar 2007 21:48:26 +0000
Subject: Re: [PATCH 1/1][DCCP] [BUG-FIX]: timer bug
Message-Id: <20070309.134826.75430651.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <200703091316.07792@strip-the-willow>
In-Reply-To: <200703091316.07792@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 10 Mar 2007 07:48:14 +1300

> On 3/10/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> > This patch initialises the write_xmit_timer in sync with the other timers, i.e.
> > the timer will be ready on any socket. This is used by applications with a
> > listening socket which start to stream after receiving an initiation by the
> > client.  The write_xmit_timer is stopped when the application closes, as before.
> >
> That makes sense. Didn't think of that case when I wrote the code for
> the timer. Thanks for fixing Gerrit.
> 
> > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Fix applied, thanks everyone.
