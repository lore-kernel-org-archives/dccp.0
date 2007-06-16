From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 16 Jun 2007 23:10:11 +0000
Subject: Re: [PATCH 6/6]: Update TX RTT sampling to use ktime_t
Message-Id: <5640c7e00706161610y6321b2dfn8e5efb5d03ac838@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706111342.08439@strip-the-willow>
In-Reply-To: <200706111342.08439@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Update TX RTT sampling to use ktime_t
>
> Using the new TX history interface (which looks up send time in ktime_t units), the
> CCID3 sender side is now upgraded to use the ktime_t interface for sampling RTT values.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
