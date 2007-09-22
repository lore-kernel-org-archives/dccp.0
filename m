From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 22 Sep 2007 20:40:46 +0000
Subject: Re: [PATCH 5/5] CCID 4: Use 1460 bytes as segment size in TCP throughput calculation
Message-Id: <5640c7e00709221340xeb43ce3gc84f38afa74ecbfe@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070920112943.GD26233@kikai.katei.fi>
In-Reply-To: <20070920112943.GD26233@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/20/07, Tommi Saviranta <wnd@iki.fi> wrote:
> +/** ccid4_first_li  -  Implements [RFC 3448, 6.3.1], with s = 1460 [TFRC-SP]

Put RFC4828 here instead of TFRC-SP.

Otherwise looks fine.
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
