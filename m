From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 08 Nov 2007 01:33:03 +0000
Subject: Re: [PATCH 8/9] [CCID2]: Remove redundant ack-counting variable
Message-Id: <5640c7e00711071733m405849a0n8f1761255c1fa38d@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200711031323.59832@strip-the-willow>
In-Reply-To: <200711031323.59832@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> The code used two different variables to count Acks, one of them redundant.
> This patch reduces the number of Ack counters to one.
>
> The type of the Ack counter has also been changed to u32 (twice the range of int);
> and the variable has been renamed into `packets_acked' - for consistency with
> RFC 3465 (and similarly named variables are used by TCP and SCTP).
>
> Lastly, a slightly less aggressive `maxincr' increment is used (for even Ack Ratios,
> maxincr was Ack Ratio/2 + 1 instead of Ack Ratio/2).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
