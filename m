From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 07 Nov 2007 18:09:32 +0000
Subject: Re: [PATCH 6/9] [CCID2]: Redundant debugging output
Message-Id: <5640c7e00711071009w6d04f883sdaebdf5b675a50eb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200711031323.52814@strip-the-willow>
In-Reply-To: <200711031323.52814@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This reduces the amount of redundant debugging messages:
>
>  * pipe/cwnd are printed in both tx_send_packet() and tx_packet_sent().
>    Both functions are called immediately after one another, so one occurrence is sufficient.
>
>  * Since tx_packet_sent() prints pipe/cwnd already, the second printk for pipe is redundant.
>
>  * In tx_packet_sent() the check_sanity function is called twice (at the begin and at the end).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
