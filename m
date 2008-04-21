From: Patrick McHardy <kaber@trash.net>
Date: Mon, 21 Apr 2008 11:45:20 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version
Message-Id: <480C7E50.3050508@trash.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Tomasz Grobelny wrote:
> Dnia Sunday 20 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82:
>> Em Sat, Apr 19, 2008 at 10:42:32PM +0200, Tomasz Grobelny escreveu:
>>>> When the patch failed to compile I thought about those alternatives.
>>>> Trying to extend the dccp_skb_cb over and above what is in there will
>>>> be messy, since the IPv4/v6 parameters are required by other
>>>> subsystems.
>>> If inet{,6}_skb_parm is used only outside DCCP code then why at all
>>> should it be placed in struct dccp_skb_cb taking up quite a lot of
>>> valuable space? Why not put it directly in struct sk_buff? Especially
>>> that it is present in struct udp_skb_cb, struct tcp_skb_cb as well.
>> Because all this is used in skb->cb[], a scratchpad for protocols to
>> use, we can go back to what we had before, that is to not reserve use
>> for inet6?_skb_parm but be sure to zero it before passing it to IP, as
>> we don't want IP to be confused with things being non zero there. Then
>> we can use all its space.
>>
> Several questions regarding this case:
> 1. What about SCTP? It doesn't have inet6?_skb_parm in it's structure tha=
t is=20
> stored in skb->cb. So does it contain a potential bug (that is to be fixe=
d)=20
> or is it not needed there or what?

Judging by a quick grep, SCTP only uses the CB on input and
appears to be fine.

> 2. If the sole purpose of this change was to keep skb->cb zeroed then it =

> doesn't seem to me like the right solution. Wasting about 20 bytes instea=
d of=20
> zeroing them when needed I would consider at least weird. I understand th=
at=20
> TCP and UDP may have enough space left but it just turned out that DCCP=20
> doesn't.

It was the safest solution that late in a release. It also
avoids to memset the cb unnecessarily. If the room is not
enough anymore, its easy to go back to using memset.

> 3. If it's IP layer that needs zeroes then why not clear skb->cb in IP la=
yer?

That would certainly work, but it adds unnecessary costs for
the other protocols that don't need this.
