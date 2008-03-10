From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 10 Mar 2008 20:28:16 +0000
Subject: Re: dccp bugs (Was: Re: panic on 2.6.24rc5)
Message-Id: <200803102128.17019.tomasz@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dnia Monday 10 of March 2008, Gerrit Renker napisa=B3:
> Now I have a question: adding 1 ms delay at the interface avoided the
> hang-up, but what do you mean by "long enough"? Is this 60 seconds?
>
I tested it for something like 100 seconds and didn't encounter any problem=
s.

> But since the average RTT is 48 microseconds in the `outfile', I am
> assuming that the outfile was produced when the delay was not added to
> the interface?
>
Yes, that's what I thought you asked me for...

> There is a long-standing problem (at least 1 year) with regard to CCID-3
> over high-speed networks (and lo interface is in fact a high-speed
> interface): high link speeds are outside the control region of CCID-3.
>
> The peak limit of controllable speed is about 12 Mbps. Everything higher
> that will cause problems. I have not tested, but you may be able to
> also silence this behaviour by using a netem token-bucket filter with
> e.g. a maximum bitrate of <=3D 10 Mbps.
>
I somehow doubt it because setting up tbf with limit greater than the actua=
l=20
traffic should have no influence at all. But let's check it...
sudo tc qdisc add dev lo root handle 1:0 tbf rate 30kbit burst 30kbit laten=
cy=20
500ms

Still the speed drops down to 1 packet per 64 seconds.

> So I think the least thing we need to do is put a warning into the DCCP
> Wiki that people should add interface delay when using CCID-3 for
> testing over loopback.
Maybe CCID-3 could somehow disable itself when it detects it is not necessa=
ry?
--=20
Regards,
Tomasz Grobelny
