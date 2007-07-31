From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 31 Jul 2007 21:16:12 +0000
Subject: Re: RFD: Ack Vectors
Message-Id: <5640c7e00707311416h66d6562p7646a8f597d3550d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200707300934.36798@strip-the-willow>
In-Reply-To: <200707300934.36798@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/30/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> With regard to the Ack Vectors, my suggestion however is
>  * to remove the sysctl - it is confusing;

Agree in current form provided the next bullet point is carried out.

>  * to make the use of Ack Vectors dependent on the current RX CCID;

It should be on for CCID2, off for CCID3. It is required for CCID2
according to RFC4341. It is optional for CCID3 according to RFC4342.
However last time I checked with our CCID3 it breaks it. I haven't
checked recently though....

>  * the TX CCID need not be considered for the Ack Vector allocation, since the `Send Ack Vector'
>    feature is server-priority (RFC 4340, 6.4) and thus negotiated by the side which has the RX CCID;

OK.

>  * optional and for debugging: disabling of Ack Vectors in the Kconfig menu.
>
This implies it is on by default. I think it should be off by default
for CCID3. The information is not actually needed from an ack vector
and actually creates more traffic. It seems like
draft-kohler-dccp-ccid3-drops-01.txt is a replacement for ack vectors
in CCID3 if you need extra info...

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
