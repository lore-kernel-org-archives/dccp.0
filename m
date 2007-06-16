From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 16 Jun 2007 20:43:22 +0000
Subject: Re: [PATCH 3/6]: Ignore trivial amounts of elapsed time
Message-Id: <5640c7e00706161343g4db7933ch9efc47ef6939de5d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706091958.18116@strip-the-willow>
In-Reply-To: <200706091958.18116@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/10/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID3]: Ignore trivial amounts of elapsed time
>
> This patch fixes a previously undiscovered bug:
>
>  * the receive timestamp is taken when the skb enters the CCID3 module;
>  * RFC 4342 requires to send an Elapsed Time estimate to the sender;
>  * the bug is in computing the elapsed time as the time between `receiving'
>    the packet (i.e. skb enters CCID module) and sending feedback,
>      --> there is no layer-processing, queueing, or delay involved,
>      --> hence the elapsed time is in the order of 1 function call
>      --> this is in the dimension of maximally 50..100usec
>      --> which renders the use of elapsed time almost entirely useless.
>
> The fix is simply to ignore such trivial amounts of elapsed time.
>
What is the bug? Do you mean it is useless to do this? Or is there
another problem?

Reading RFC4340, 13.2 and thinking about pre-emptible kernels causes
me to ask this question - what happens if you lose the time slice you
are on in between the calls - then it would be much higher time
difference....

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
