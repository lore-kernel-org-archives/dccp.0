From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 04:34:49 +0000
Subject: Re: [PATCH 4/10]: Basic support for passive-close
Message-Id: <5640c7e00709052134o653c12a7w2886ba98e21194e2@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 7/13/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Basic support for passive-close
>
> This implements necessary state transitions for the two forms of passive-close
>
>  * PASSIVE_1, which is entered when a host receives Close;
>  * PASSIVE_2, which is entered when a client receives CloseReq.
>
> The handling is such that these passive connection-termination requests are
> enqueued as `fin' packets so that dccp_recvmsg() can later detect them. The
> only thing I am not entirely sure about is the wake_async in dccp_rcv_closereq();
> this has been copied from dccp_rcv_close() (but looks ok from the principle).
>
> The completed state transition diagram is on
> http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/closing_states/
>
> NB: Regrettably, it is no longer easily possible to use a table-based transition as
>     before. The reason is that the role of the host (server or client) also plays a
>     `role' in the state transition. Therefore DCCP_ACTION_FIN has also been removed.
>     Another difference is that the transition into DCCP_CLOSED is now after sending
>     the Close/CloseReq.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
