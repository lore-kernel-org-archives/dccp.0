From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Wed, 19 Sep 2007 21:46:32 +0000
Subject: Re: CCID 3 and CCID 4 to streaming adaptation
Message-Id: <5bc4c4570709191446v1c477dffl4f4091afc94e9abd@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709191331y5696a14o96e35b5d6124b641@mail.gmail.com>
In-Reply-To: <5bc4c4570709191331y5696a14o96e35b5d6124b641@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Very good! I still not complete the reading for CCID-4 draft. In all
case, nice to know this because I have also a particular interesting
on it as I said to you last time we talked about speex.

Leandro.

2007/9/19, Tommi Saviranta <wnd@iki.fi>:
> On Wed, Sep 19, 2007 at 17:31:57 -0300, ツ Leandro Sales wrote:
> > it RFC 4342, section 5.3 (Packet Sizes), it says that CCID-3 is not
> > appropriate for applications that require a fixed interval of time
> > between packets and vary their packet size instead of their packet
> > rate in response to congestion. The question is: in this case it is
> > not recommended to use VBR codecs such as SPEEX on the application
> > layer? Is this same issue occurs in the CCID-4?
>
> I interpret RFC 4342 exactly the way you do. CCID 3 is suitable for
> applications such as online gaming, but not for variable bitrate codecs.
>
> CCID 4 draft (draft-floyd-dccp-ccid4-01.txt), section 3:
>
>  "CCID 4 is designed to be used either by applications that use a small
>   fixed segment size, or by applications that change their sending rate
>   by varying the segment size.  If CCID 4 is used by an application that
>   varies its segment size in response to changes in the allowed sending
>   rate in bps, we note that CCID 4 doesn't dictate the segment size to
>   be used by the application; this is done by the application itself."
>
> The way I understand this, CCID 4 is The Choice(tm) for VBR codecs such
> as Speex, which is also one of the main reasons I'm interested in
> CCID 4.
>
>
