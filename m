From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Nov 2006 21:30:04 +0000
Subject: Re: Packet size s Re: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <5640c7e00611281330r2325b16bxff29956d2d5776df@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
In-Reply-To: <5640c7e00611281246m6e44de93j4b2c34b73040679f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> OK, additionally I'm replacing:
>
> +               DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
> +               err = -EINVAL;
>
> By
>
> +               DCCP_WARN("sockopt(PACKET_SIZE) not yet supported\n");
> +               err = -EINVAL;
>
> To better reflect what we've discussed so far.
>
No deprecate it still. My earlier patches split it into two - a tx and
rx packet size.

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
