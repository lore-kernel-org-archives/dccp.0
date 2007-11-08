From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 08 Nov 2007 01:33:54 +0000
Subject: Re: [PATCH 9/9] [CCID2]: Remove misleading comment
Message-Id: <5640c7e00711071733q4c9af3c4h45b62bfa687479d1@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200711031324.02949@strip-the-willow>
In-Reply-To: <200711031324.02949@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This removes a comment which identifies an `issue' with dccp_write_xmit() where there is none.
> The comment assumes it is possible that a packet is sent between the calls to
>
>         ccid_hc_tx_send_packet(),
>         dccp_transmit_skb(),
>         ccid_hc_tx_packet_sent()
>
> (in the above order) in dccp_write_xmit().
>
> I think that this is impossible, since dccp_write_xmit() is always called under lock:
>
>  * when called as dccp_write_xmit(sk, 1) from dccp_send_close(), the socket is locked
>    (see code comment above dccp_send_close());
>  * when called as dccp_write_xmit(sk, 0) from dccp_send_msg(), it is after lock_sock() has been called;
>  * when called as dccp_write_xmit(sk, 0) from dccp_write_xmit_timer(), bh_lock_sock() has been called
>    and the if/else statement has made sure that sk_lock.owner is not set;
>  * there are no other places where dccp_write_xmit() is called.
>
> Furthermore, the debug statement for printing the sequence number of the packet just sent has been
> removed, since the entire list is being printed anyway and so the entry of that number appears last.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
