From: Colin Perkins <csp@csperkins.org>
Date: Wed, 18 Apr 2007 16:16:03 +0000
Subject: Re: [dccp] Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <78035AF4-DDD7-4C40-BBC1-992DC01245AC@csperkins.org>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11 Apr 2007, at 23:45, Ian McDonald wrote:
> On 4/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>> There is no way to stop a Linux CCID3 sender from ramping X up to  
>> the link bandwidth of 1 Gbit/sec; but the scheduler can only  
>> control packet pacing up to a rate of s * HZ bytes per second.
>
> Let's start to think laterally about this. Many of the problems around
> CCID3/TFRC implementation seem to be on local LANs and rtt is less
> than t_gran. We get really badly affected by how we do x_recv etc and
> the rate is basically all over the show. We get affected by send
> credits and numerous other problems.

As a data point, we've seen similar stability issues with our user- 
space TFRC implementation, although at somewhat larger RTTs (order of  
a few milliseconds or less). We're still checking whether these are  
bugs in our code, or issues with TFRC, but this may be a broader  
issue than problems with the Linux DCCP implementation.

Colin
