From: "Edgar E. Iglesias" <edgar.iglesias@axis.com>
Date: Mon, 28 Aug 2006 06:35:02 +0000
Subject: Re: [dccp] Re: low tx speed in ccid3 after loss
Message-Id: <20060828063502.GB15693@edgar.underground.se.axis.com>
List-Id: <dccp.vger.kernel.org>
References: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
In-Reply-To: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, Aug 28, 2006 at 08:17:49AM +0200, Edgar E. Iglesias wrote:
> On Sun, Aug 27, 2006 at 04:33:15PM +1200, Ian McDonald wrote:
> > Burak wrote on the Linux DCCP mailing list:
> > >> After applying Ian's patches (except for bestpacketnext) I did some 
> > >tests with ccid3 and came across a problem. In some cases when packet loss 
> > >occurs, transmit rate drops down and stays there, with almost no increase. 
> > >Besides, p value is set to a value bigger than zero after the loss, and 
> > >does not change again, although no loss occurs - which may be the 
> > >explanation of the unchanging tx rate ???
> > >
> > 
> > I have a question for people. If DCCP detects loss once and once only
> > (as I suspect is happening here (Burak - can you confirm through a
> > packet trace please?) then I haven't read anything in the spec of TFRC
> > or CCID3 which says that you can lower the loss rate later on when you
> > don't have a loss. As I read the spec you only recalculate the loss
> > rate when you get a loss and thus if you have a loss when you are
> > starting you have a real issue.
> 
> Hi Ian,
> 
> I beleive you need to recompute the loss rate on every received data packet.
> While there is no packet loss, the average loss interval will increase and 
> p will decrease.

Some second thoughts :)

Maybe you can get away with recomputing p only when the time allows us to 
send a new feedback packet.

Best regards
-- 
        Programmer
        Edgar E. Iglesias <edgar.iglesias@axis.com> 46.46.272.1946
