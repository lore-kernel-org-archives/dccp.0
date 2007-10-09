From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 09 Oct 2007 20:10:56 +0000
Subject: Re: [PATCH 1/1]: Test tree update (was Re: [PATCH 3/10]: Dedicated auxiliary states to support passi
Message-Id: <5640c7e00710091310n65a845ddn19d7c82fee703b1e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 10/10/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: More informative state names
>
> This realises a naming scheme due to Arnaldo Carvalho de Melo (many thanks), which
> assigns more informative/declarative names to the auxiliary and intermediate states
> PASSIVE_1/2i - which exist to facilitate passive-Close:
>
>         s/PASSIVE_1/DCCP_PASSIVE_CLOSE/g;       /* any node receiving a Close */
>         s/PASSIVE_2/DCCP_PASSIVE_CLOSEREQ/g;    /* when client receives CloseReq */
>
> In addition, to better separate between sending and receiving a CloseReq,
>
>         s/CLOSEREQ/DCCP_ACTIVE_CLOSEREQ/g;      /* server sending a CloseReq */
>
> However, for pretty-printing and system logs, the name of the last state remains
> at `CLOSEREQ', for consistency.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
