From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 16 Jun 2007 20:48:06 +0000
Subject: Re: [PATCH 4/6]: Simplify interface of dccp_sample_rtt
Message-Id: <5640c7e00706161348i1b45d387j87780284db276eb8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091958.27168@strip-the-willow>
In-Reply-To: <200706091958.27168@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/10/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Simplify interface of dccp_sample_rtt

Don't quite understand this yet but that's just me needing to look at
longer I think!!
>
> +extern u32        dccp_sample_rtt(struct sock *sk, long candidate);
>
What's candidate? Do you mean delta perhaps?

> +u32 dccp_sample_rtt(struct sock *sk, long delta)
>  {
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
