From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 08 Mar 2008 04:59:55 +0000
Subject: Re: Existing solutions for encapsulation?
Message-Id: <5640c7e00803072059u34e3cc1foe86124da7c46fa27@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <47CEF714.708@variadic.org>
In-Reply-To: <47CEF714.708@variadic.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, Mar 6, 2008 at 8:40 AM, Steven Brown <swbrown@variadic.org> wrote:
> I'm running into a need for encapsulation due to various providers
>  mangling (mandatory NATs on local EVDO service) or dropping (AT&T Yahoo
>  DSL residential service (but business service works it seems)) DCCP
>  traffic.  I figure DCCP-NAT[1] support in the stack is exactly what I
>  need, but AFAIK it's not implemented yet (only in DCCP-TP I think).
>
>  Is there an existing solution at the moment to add the encoding, or near
>  term plan to implement it?  If not, would it make sense to route the
>  traffic into a tun device that adds/removes the encoding?  Is there a
>  better way to get the DCCP packet before it's sent than having an extra
>  service/interface like that?  I'm not familiar enough with the kernel
>  layer to implement it there in reasonable time which is why I'm looking
>  at doing a quick hack in userland.
>
>
>  [1] http://www.phelan-4.com/dccp/draft-phelan-dccp-natencap-00.txt
>
Steven,

I'm not aware of anybody working on this in the kernel at present -
this is relatively new though. I would love to, but don't have the
time. Basically things get into the kernel by people having a go. A
quick hack in userland would work, but I would say give it a go in
kernel as well - no time to learn like the present!

The other option is seeing if you can port it from DCCP-TP to the
kernel. It is meant to be a portable implementation....

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
