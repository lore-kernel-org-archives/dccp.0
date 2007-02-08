From: Eddie Kohler <kohler@icir.org>
Date: Thu, 08 Feb 2007 00:39:43 +0000
Subject: Re: [dccp] Question on resetting nominal send time
Message-Id: <45CA714F.8030200@icir.org>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00701161351q19360335mf2862a31596ae94a@mail.gmail.com>
In-Reply-To: <5640c7e00701161351q19360335mf2862a31596ae94a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

WHOOPSY!  I wrote t_ipi when I meant t_nominal, or whatever symbol you choose 
for "the time the next packet is allowed to be sent".  t_ipi should not be 
changed; it depends on X_inst.

Eddie Kohler wrote:
> If t_ipi is used to schedule transmissions, then the following equation 
> should be applied each time the application is scheduled:
> 
>    t_ipi := max(t_ipi, t_now - RTT/2)

SHOULD BE

      t_nominal := max(t_nominal, t_now - RTT/2)

>     t_ipi := max(t_ipi, t_now - t_gran).

SHOULD BE

      t_nominal := max(t_nominal, t_now - t_gran)

Sorry!
Eddie
