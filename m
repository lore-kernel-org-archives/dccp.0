From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 04 Jan 2007 22:45:00 +0000
Subject: Re: [PATCH 1/5]: DCCP Fix use of invalid loss intervals
Message-Id: <5640c7e00701041445x13d3936bxbb03fda0e181b553@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201544.22122.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201544.22122.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/5/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> But the two bit patterns are the same, and the comparison will promote
> them both to unsigned.
>
When I test from userspace I reach the same conclusion.

However without that patch in the kernel I get problems.

We have been having some weird signed/unsigned stuff going on - I'm
wondering if its something in the kernel build environment as it is
quite bizarre at times....

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
