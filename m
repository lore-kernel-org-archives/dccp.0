From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 24 Jan 2007 03:00:55 +0000
Subject: Re: [PATCH 6/7]: Sample RTT from SYN exchange
Message-Id: <5640c7e00701231900u279e886cy9d62f4460a9baf42@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701231541.11648@strip-the-willow>
In-Reply-To: <200701231541.11648@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 24/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Sample RTT from SYN exchange
>
My initial thoughts on this is that the concept is quite similar to
mine as we both get it from request/response feedback. Totally agree
that it is the right thing to do.

My code seems simpler but yours seems better structured. Not that that
matters anyway!!

I haven't read the code properly so this is probably a stupid
question. Doesn't this rely on the receiver sending back the RTT which
it can't know at that point of time?? It's only had the request then
so rtt can only be determined by the receiver. But I could be wrong
here and I will go back and read the code/rfcs when back at home.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
