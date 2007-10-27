From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 27 Oct 2007 22:17:26 +0000
Subject: Re: [PATCH 2/6]: Bug in reading Ack Vectors
Message-Id: <5640c7e00710271517yd6969c0k5f30db1eef70dfb6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710271234.21096@strip-the-willow>
In-Reply-To: <200710271234.21096@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/28/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID2]: Bug in reading Ack Vectors
>
> In CCID2 the receiver-history is sorted in ascending order of sequence number,
> but the processing of received Ack Vectors requires the list traversal in the
> opposite direction.
>
> The current code has a bug in this regard: the list traversal is upwards. As a
> consequence, only Ack Vectors with a run length of 1 will pass, in all other
> Ack Vectors the remaining (acked) sequence numbers are missed, and may later
> falsely be identified as lost.
>
> Note: This bug is only visible when Ack Ratio > 1, since otherwise the run
>       lengths of Ack Vectors are 0.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
