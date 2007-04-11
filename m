From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 11 Apr 2007 02:55:08 +0000
Subject: Re: [PATCH 4/5]: Rate-limit DCCP-Syncs
Message-Id: <5640c7e00704102000r7bfc5111s253c1aef3b85ed06@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200704091058.57313@strip-the-willow>
In-Reply-To: <200704091058.57313@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/9/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Rate-limit DCCP-Syncs
>
> This implements a SHOULD from RFC 4340, 7.5.4:
>  "To protect against denial-of-service attacks, DCCP implementations SHOULD
>   impose a rate limit on DCCP-Syncs sent in response to sequence-invalid packets,
>   such as not more than eight DCCP-Syncs per second."
>
OK I take back my comment earlier about doing rate limiting in earlier
message as I hadn't read the justification for it.


> +sync_ratelimit = HZ/8
> +       The timeout between subsequent DCCP-Sync packets sent in response to
> +       sequence-invalid packets on the same socket (RFC 4340, 7.5.4). The unit
> +       of this parameter is jiffies; a value of 0 disables rate-limiting.
> +

No, no, no. A userspace parameter in jiffies is just wrong I think.
You change HZ and this doesn't automatically change. You could be
doing this with different kernels on your machine even and setting
sysctls in a file. Take a bit of time and put this in milliseconds.


-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
