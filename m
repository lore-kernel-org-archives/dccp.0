From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 24 Jun 2007 21:27:30 +0000
Subject: Re: [PATCH 2/5]: History access is redundant when sending feedback
Message-Id: <5640c7e00706241427w21411eccya69a1ca357293508@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706141005.07993@strip-the-willow>
In-Reply-To: <200706141005.07993@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/14/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: History access is redundant when sending feedback
>
>
> This patch
>   1. removes redundant use of packet history for sending feedback
>      (data packet is no longer `found', just referenced);
>   2. which obsoletes function dccp_rx_hist_find_data_packet - removed;
>   3. removes an irrelevant state `TERM' (feedback is then not sent);
>   4. removes redundant variable `last_ack' (duplicates `last_feedback');
>   5. converts rx_send_feedback() to use the newer timeofday interface;
>   6. simplify the computation of p/p_inv (see note below).
>
Great - making code much simpler - makes it easier for people like me
to understand!

> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
