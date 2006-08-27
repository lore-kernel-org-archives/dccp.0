From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 27 Aug 2006 04:33:15 +0000
Subject: Re: low tx speed in ccid3 after loss
Message-Id: <5640c7e00608262133qc0308a1o6ce50554fa83508d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
In-Reply-To: <20060827030500.9618.qmail@web30003.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Burak wrote on the Linux DCCP mailing list:
> > After applying Ian's patches (except for bestpacketnext) I did some tests with ccid3 and came across a problem. In some cases when packet loss occurs, transmit rate drops down and stays there, with almost no increase. Besides, p value is set to a value bigger than zero after the loss, and does not change again, although no loss occurs - which may be the explanation of the unchanging tx rate ???
>

I have a question for people. If DCCP detects loss once and once only
(as I suspect is happening here (Burak - can you confirm through a
packet trace please?) then I haven't read anything in the spec of TFRC
or CCID3 which says that you can lower the loss rate later on when you
don't have a loss. As I read the spec you only recalculate the loss
rate when you get a loss and thus if you have a loss when you are
starting you have a real issue.

Am I missing something obvious here? I probably am but I can't quite
see at the moment - can someone point it out to me. As I read it the
calculation is based on this part of the TFRC spec:
             If (p > 0)
                 Calculate X_calc using the TCP throughput equation.
                 X = max(min(X_calc, min_rate), s/t_mbi);
If p doesn't change then X_calc doesn't change and therefore you can't
go above X_calc

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
