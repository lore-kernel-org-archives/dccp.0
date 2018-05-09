From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 09 May 2018 17:31:44 +0000
Subject: Re: [PATCH net-next v3 0/2] socket statistics for ss
Message-Id: <20180509103144.195e7494@xeon-e3>
List-Id: <dccp.vger.kernel.org>
References: <20180507184333.32688-1-sthemmin@microsoft.com>
In-Reply-To: <20180507184333.32688-1-sthemmin@microsoft.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, 9 May 2018 10:18:23 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On 05/09/2018 08:22 AM, Stephen Hemminger wrote:
> 
> > I am not sure if these patches are worth applying.
> > The 'ss -s' command has had missing values since 2.4 kernel.
> > And the first complaints came in only this year.
> > 
> > Another alternative would be just to remove these fields from ss -s
> > output and move on.
> >   
> 
> Anyway your patches are not netns ready, so lets remove these fields from ss.
> 
> Or you have to spend _much_ more time on writing and testing the kernel part.
> 
> Thanks.

The patches only expose the existing TCP socket accounting infrastructure.
Several other pieces that sockstat has are not netns aware.
That is a completely different problem.
