From: Patrick McHardy <kaber@trash.net>
Date: Tue, 22 Apr 2008 04:56:26 +0000
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked version
Message-Id: <480D6FFA.80205@trash.net>
List-Id: <dccp.vger.kernel.org>
References: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080414073915.GA9655@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Tomasz Grobelny wrote:
> Dnia Monday 21 of April 2008, Arnaldo Carvalho de Melo napisa=C5=82:
>> Nod, if we don't need the space reserved for the lower layer protocols
>> in DCCP it is actually the best solution, as we don't need to zero the
>> cb again before passing it to IP, it gets zeroed at alloc_skb time and
>> that is it. If we need the space, we have to pay the price of
>> memset before passing to IP.
>>
> Ok, so in this case the patch for DCCP could be reverted in test tree, is=
 that=20
> right? Were these two deleted memsets zeroing all that was necessary or w=
ere=20
> there any other bugs fixed by the patch?

No, those two memsets became unnecessary by the addition
of the new cb members. If you want to remove them again,
you need to add those memsets back and additionally add
memsets that zero the first sizeof(inet_skb_parm)/
sizeof(inet6_skb_parm) bytes everywhere else where packets
are passed to IP(v6).
