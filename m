From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 09 May 2018 17:18:23 +0000
Subject: Re: [PATCH net-next v3 0/2] socket statistics for ss
Message-Id: <be94fb64-1dd5-e512-50d6-16a1b7d4d092@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20180507184333.32688-1-sthemmin@microsoft.com>
In-Reply-To: <20180507184333.32688-1-sthemmin@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



On 05/09/2018 08:22 AM, Stephen Hemminger wrote:

> I am not sure if these patches are worth applying.
> The 'ss -s' command has had missing values since 2.4 kernel.
> And the first complaints came in only this year.
> 
> Another alternative would be just to remove these fields from ss -s
> output and move on.
> 

Anyway your patches are not netns ready, so lets remove these fields from ss.

Or you have to spend _much_ more time on writing and testing the kernel part.

Thanks.
