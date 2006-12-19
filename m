From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 19 Dec 2006 23:06:56 +0000
Subject: Re: [PATCH 0/8]: Sequence numbers, larger windows revisited, minor cleanups
Message-Id: <5640c7e00612191506u41ba5907oaf073ab7d2a50354@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612151049.50073@strip-the-willow>
In-Reply-To: <200612151049.50073@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/19/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> I am not fussy about getting the patches into 2.6.20 at all cost. I am reconsidering
> the add48/sub48 and the dccp_inc_seqno functions/macros.
>
Gerrit,

I think leave your code in as it covered more cases than mine and it
works - I've been doing quite a bit of testing of CCID3 and I'm happy
with your code as per your patch series.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
