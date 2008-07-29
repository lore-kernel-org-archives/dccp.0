From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 29 Jul 2008 22:39:02 +0000
Subject: Re: [PATCH 5/7] dccp tfrc: Increase number of RTT samples
Message-Id: <5640c7e00807291539o4a116aebta34dea1dc8eb3081@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <1217325952-12337-6-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1217325952-12337-6-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Jul 29, 2008 at 10:05 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This improves the receiver RTT sampling algorithm so that it tries harder to get
> as many RTT samples as possible, using several optimisations.
>
> Applicability and background
> ----------------------------
> The algorithm uses timestamps and differences of the CCval window counter to
> guess the RTT, using concepts presented in RFC 4340, 8.1.
>
> There exist 4 cases for the CCVal difference:
>  * = 0: less than RTT/4 passed since last packet -- unusable sample;
>  *  > 4: (much) more than 1 RTT has passed since last packet -- also unusable;
>  * = 4: "perfect" sample (exactly one RTT has passed since last packet);
>  * 1..3: sub-optimal sample (between RTT/4 and 3*RTT/4 has passed).
>
> In the last case the algorithm so far tried to optimise by storing away the
> candidate and then re-trying next time. This had the following problems:
>  * a large number of samples is needed to smooth out the given inaccuracies;
>  * the sender may not be sending enough packets to warrant a "next time";
>  * hence it is better to use suboptimal samples whenever possible.
> As a consequence, the algorithm now stores away the current sample only if the
> difference is 0.
>
> A realistic example to illustrate the failure of the (previous) algorithm is MP3
> streaming, where packets are sent at a rate of less than one packet per RTT.
> Which means that suitable samples may be absent for a very long time.
>
> The effectiveness of using suboptimal samples (with a delta between 1 and 4) was
> confirmed by instrumenting the algorithm with counters. The results of two 20
> second test runs were:
>  * With the old algorithm and a total of 38442 function calls, only 394 of these
>   calls resulted in usable RTT samples (about 1%), 378 out of these were
>   "perfect" samples, and 28013 (unused) samples had a delta of 1..3.
>  * With the new algorithm and a total of 37057 function calls, 1702 usable RTT
>   samples were retrieved (about 4.6%), 5 out of these were "perfect" samples.
> This means an almost five-fold increase in the number of samples.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Great work. This should make a real improvement.

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
