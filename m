From: Sally Floyd <sallyfloyd@mac.com>
Date: Mon, 05 Mar 2007 04:06:05 +0000
Subject: Re: [dccp] Re: CCID 3 question: length of the `open' loss interval I_0
Message-Id: <748e4dd1f6f6eb0c0929affbbabc97cd@mac.com>
List-Id: <dccp.vger.kernel.org>
References: <200701091321.00592@strip-the-willow>
In-Reply-To: <200701091321.00592@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Eddie -

(Apologies, I am getting to email later and later...)

> However, to be honest, I'd say that RFC3448 appears to define it as 
> "number of packets received since last loss event".  I think this is a 
> misstatement in RFC3448 and should be considered for fixing in 
> RFC3448bis.  Every other loss interval is defined as a length in 
> sequence space INCLUDING lost and marked packets (RFC3448 5.3).

Yep.  Fixed.

Many thanks.

- Sally
http://www.icir.org/floyd/

