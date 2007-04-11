From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 11 Apr 2007 02:26:32 +0000
Subject: Re: [PATCH 28/43]: Make computation of X_recv conform to TFRC
Message-Id: <5640c7e00704101926t2fec7f06m8edd44041c4b35bb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200704051636.00836@strip-the-willow>
In-Reply-To: <200704051636.00836@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/6/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Make computation of X_recv conform to TFRC
>
> The computation of X_recv does currently not conform to TFRC/RFC 3448,
> since this specification requires that X_recv be computed over the last
> R_m seconds (sec. 6.2).
> The code, in contrast, computes X_recv over the time the last feedback was
> sent. This results in sending wrong estimates of X_recv, making it impossible
> for the sender to find its allowed sending rate.
>

I think this is one of those (rare) instances where RFC4342 overrides
RFC3448. Have a look in particular at section 10.3 of 4342 and 8.1/8.3

As such this patch is not correct I think.

Thoughts?

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
